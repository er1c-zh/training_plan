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
        GlobalInst.logger.info("recordListTransformer transformedValueClass")
        return NSData.self
    }

    public override func transformedValue(_ value: Any?) -> Any? {
        GlobalInst.logger.info("recordListTransformer transformedValue")
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

        GlobalInst.logger.info("recordListTransformer \(result)")

        return result.data(using: .utf8)
    }

    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        GlobalInst.logger.info("recordListTransformer reverseTransformedValue")
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
            } else {
                GlobalInst.logger.info("reverseTransformedValue convert to string fail")
            }
        } else {
            GlobalInst.logger.info("reverseTransformedValue convert to Data fail")
        }
        GlobalInst.logger.info("reverseTransformedValue \(result == nil)")
        if let result = result {
            GlobalInst.logger.info("reverseTransformedValue \(result)")
        }
        return result
    }

    public override class func allowsReverseTransformation() -> Bool {
        GlobalInst.logger.info("recordListTransformer allowsReverseTransformation")
        return true
    }
}

extension NSValueTransformerName {
    static let recordListTransformer = NSValueTransformerName(rawValue: "recordListTransformer")
}


extension Training {

    struct Data {
        var recordList: [Record.Data]
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

        GlobalInst.logger.info("Training update start")

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

        GlobalInst.logger.info("Training update finish update and create")

        recordList?.forEach { r in
            if dicRecordID2RecordData[r.recordID] == nil {
                GlobalInst.GetContext().delete(r)
            }
        }

        GlobalInst.logger.info("Training update finish delete")

        recordList = tmpList
        GlobalInst.logger.info("Training update done")
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
            let context = PersistenceController.shared.container.viewContext
            let result = try context.fetch(fr)
            GlobalInst.logger.info("getDoingTraining result \(result)")
            GlobalInst.logger.info("getDoingTraining result \(result.first == nil)")
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

    static func getTrainingList() -> [Training] {
        let fr = NSFetchRequest<Training>()
        fr.entity = Training.entity()
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Training.trainingID, ascending: false)
        ]
        do {
            let context = PersistenceController.shared.container.viewContext
            let result = try context.fetch(fr)
            GlobalInst.logger.info("getDoingTraining result \(result)")
            return result
        } catch {
            GlobalInst.logger.error("getDoingTraining fail")
            return []
        }
    }
}
