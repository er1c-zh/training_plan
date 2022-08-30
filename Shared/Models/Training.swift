//
// Created by eric on 2022/8/6.
//

import Foundation
import CoreData

// extension PlanItem {
//     struct Data {
//         var Weight: Double = 0
//         var CountPerRound: Int64 = 0
//         var CntOfRound: Int64 = 0
//         var IntervalInSeconds: Int64 = 0
//     }
//
//     var data: Data {
//         Data(Weight: Weight, CountPerRound: CountPerRound, CntOfRound: CntOfRound, IntervalInSeconds: IntervalInSeconds)
//     }
//
//     mutating func update(from data: Data) {
//         Weight = data.Weight
//         CountPerRound = data.CountPerRound
//         CntOfRound = data.CntOfRound
//         IntervalInSeconds = data.IntervalInSeconds
//     }
//
// }

public final class recordListTransformer : ValueTransformer {
    public override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    public override func transformedValue(_ value: Any?) -> Any? {
        var result: String = ""
        if let typed = value as? [Record] {
            var idList:  [String] = []
            for r in typed {
                idList.append(String(format: "%ld", r.recordID))
            }
            result = idList.joined(separator: ",")
        } else {
            result = ""
        }

        return result.data(using: .utf8)
    }

    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        var result: [Record]? = nil
        if let data = value as? Data {
            let typed = String(data: data, encoding: .utf8)
            if let typed = typed {
                let idList = typed.split(separator: ",")
                var recordList: [Record] = []
                for idStr in idList {
                    let id: Int64? = Int64(idStr)
                    if (id != nil) {
                        let record = Record.getRecordListByRecordID(recordID: id!)
                        if record != nil {
                            recordList.append(record!)
                        }
                    }
                }
                result = recordList
            }
        }
        return result
    }

    public override class func allowsReverseTransformation() -> Bool {
        return true
    }
}

extension NSValueTransformerName {
    static let recordListTransformer = NSValueTransformerName(rawValue: "recordListTransformer")
}


extension Training {

    struct Data {
        var recordList: [Record.Data] = []
    }

    var data: Data {
        var d = Data(recordList: [])
        if let recordList = recordList {
            for r in recordList {
                d.recordList.append(r.data)
            }
        }
        return d
    }

    func update(from data : Data) {
        var dicRecordID2RecordData: [Int64: Record.Data] = [:]
        data.recordList.forEach { rd in
            dicRecordID2RecordData[rd.id] = rd
        }
        var dicRecordID2Record: [Int64: Record] = [:]
        recordList?.forEach { r in
            dicRecordID2Record[r.recordID] = r
        }

        var tmpList: [Record] = []

        data.recordList.forEach { rd in
            if let r = dicRecordID2Record[rd.id] {
                r.update(from: rd)
                tmpList.append(r)
            } else {
                let r = Record(context: GlobalInst.GetContext())
                r.status = 0
                r.update(from: rd)
                tmpList.append(r)
            }
        }

        recordList?.forEach { r in
            if dicRecordID2RecordData[r.recordID] == nil {
                GlobalInst.GetContext().delete(r)
            }
        }

        recordList = tmpList
    }

    enum Status: Int16 {
        case statusInit = 0;
        case statusDoing = 1;
        case statusDone = 2;
        case statusCanceled = 3;
        case statusTemplate = 4;
    }

    static func getDoingTraining() -> Training? {
        let fr = NSFetchRequest<Training>()
        fr.entity = Training.entity()
        fr.fetchLimit = 1
        fr.predicate = NSPredicate(format: "status == %d", Int(Training.Status.statusDoing.rawValue))
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Training.trainingID, ascending: false)
        ]
        do {
            let result = try GlobalInst.GetContext().fetch(fr)
            if result.count > 0 {
                return result[0]
            } else  {
                return nil
            }
        } catch {
            GlobalInst.logger.error("getDoingTraining fail")
            return nil
        }
    }

    static private var strategy: Training = loadStrategyTraining()

    public static func getStrategy() -> Training {
        // format strategy
        // add unknown exerciseType
        // remove duplicate exerciseType
        var newRecordList: [Record] = []
        var i = 0
        var j = 0
        var isDelta = false
        let exerciseTypeList = ExerciseType.getAllExerciseType()
        let oldRecordList: [Record] = strategy.recordList == nil ? [] : strategy.recordList!

        while i < exerciseTypeList.count && j < oldRecordList.count {
            if exerciseTypeList[i].rawValue > oldRecordList[j].exerciseType {
                isDelta = true
                j += 1
            } else if exerciseTypeList[i].rawValue < oldRecordList[j].exerciseType {
                isDelta = true
                let tmp = Record.init(context: GlobalInst.GetContext())
                tmp.recordID = GlobalInst.GetMillisecondTimestamp()
                tmp.exerciseType = exerciseTypeList[i].rawValue
                newRecordList.append(tmp)
                i += 1
            } else {
                newRecordList.append(oldRecordList[j])
                i += 1
                j += 1
            }
        }

        while i < exerciseTypeList.count {
            isDelta = true
            let tmp = Record.init(context: GlobalInst.GetContext())
            tmp.recordID = GlobalInst.GetMillisecondTimestamp()
            tmp.exerciseType = exerciseTypeList[i].rawValue
            newRecordList.append(tmp)
            i += 1
        }
        if j < oldRecordList.count {
            isDelta = true
        }

        if isDelta {
            strategy.recordList = newRecordList
            GlobalInst.SaveContext()
        }

        return strategy
    }

    static private func loadStrategyTraining() -> Training {
        let fr = NSFetchRequest<Training>()
        fr.entity = Training.entity()
        fr.fetchLimit = 1
        fr.predicate = NSPredicate(format: "status == %d", Int(Training.Status.statusTemplate.rawValue))
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Training.trainingID, ascending: false)
        ]
        var strategyTraining: Training
        do {
            let result = try GlobalInst.GetContext().fetch(fr)
            if result.count > 0 {
                strategyTraining = result[0]
            } else {
                strategyTraining = Training.init(context: GlobalInst.GetContext())
                strategyTraining.trainingID = -1 /* TODO fix this */
                strategyTraining.status = Training.Status.statusTemplate.rawValue
                GlobalInst.SaveContext()
            }
        } catch {
            fatalError()
        }
        return strategyTraining
    }

    static func getTrainingList() -> [Training] {
        let fr = NSFetchRequest<Training>()
        fr.entity = Training.entity()
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Training.trainingID, ascending: false)
        ]
        do {
            let result = try GlobalInst.GetContext().fetch(fr)
            return result
        } catch {
            GlobalInst.logger.error("getDoingTraining fail")
            return []
        }
    }
}
