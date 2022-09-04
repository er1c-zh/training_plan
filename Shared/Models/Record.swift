//
// Created by eric on 2022/8/27.
//

import Foundation
import CoreData

extension Record {
    enum Status: Int16 {
        case initing = 0
        case doing = 1
        case done = 2
        case deleted = 3
    }

    struct Data: Identifiable {
        var id: Int64 = GlobalInst.GetMillisecondTimestamp()
        var exerciseType: Int16 = ExerciseType.Unknown.rawValue
        var rep: Int64 = 0
        var tag: String? = ""
        var type: Int16 = 0
        var weight: Double = 0
        var weightUnit: Int16 = 0
        var restInSec: Int64 = 0
    }


    var data: Data {
        Data(id: recordID, exerciseType: exerciseType, rep: rep, tag: tag, type: type, weight: weight, weightUnit: weightUnit)
    }

    func update(from data: Data) {
        exerciseType = data.exerciseType
        rep = data.rep
        tag = data.tag
        type = data.type
        weight = data.weight
        weightUnit = data.weightUnit
        recordID = data.id
        restInSec = data.restInSec
    }

    static func getRecordByRecordID(recordID: Int64) -> Record? {
        GlobalInst.logger.info("getRecordListByRecordID start")
        let fr = NSFetchRequest<Record>()
        fr.entity = Record.entity()
        fr.predicate = NSPredicate(format: "recordID == %ld", recordID)
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.startTimestamp, ascending: true),
            NSSortDescriptor(keyPath: \Record.order, ascending: true)
        ]
        do {
            let context = PersistenceController.shared.container.viewContext
            let result = try context.fetch(fr)
            return result.first
        } catch {
            if let error = error as NSError? {
                GlobalInst.logger.error("getRecordListByRecordID fail \(error)")
            }
            GlobalInst.logger.error("getRecordListByRecordID fail")
            return nil
        }
    }

    static func getRecordListExceptTemplate() -> [Record] {
        let fr = NSFetchRequest<Record>()
        fr.entity = Record.entity()
        fr.predicate = NSPredicate(format: "status == %d", RecordStatus.statusTemplate.rawValue)
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.recordID, ascending: true),
        ]
        do {
            let context = PersistenceController.shared.container.viewContext
            let result = try context.fetch(fr)
            return result
        } catch {
            GlobalInst.logger.error("getRecordListByRecordID fail")
            return []
        }
    }

    static func getRecordList() -> [Record] {
        let fr = NSFetchRequest<Record>()
        fr.entity = Record.entity()
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.recordID, ascending: true),
        ]
        do {
            let context = PersistenceController.shared.container.viewContext
            let result = try context.fetch(fr)
            return result
        } catch {
            GlobalInst.logger.error("getRecordListByRecordID fail")
            return []
        }
    }

    static func getLastDoneFormalRecordByExerciseType(et: ExerciseType) -> Record? {
        let fr = NSFetchRequest<Record>()
        fr.entity = Record.entity()
        fr.predicate = NSPredicate(format: "exerciseType == %d AND type == %d AND status == %d",
                et.rawValue, RecordType.typeFormal.rawValue, RecordStatus.statusDone.rawValue)
        fr.fetchLimit = 1
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.recordID, ascending: false),
        ]
        do {
            let context = PersistenceController.shared.container.viewContext
            let result = try context.fetch(fr)
            return result.first
        } catch {
            GlobalInst.logger.error("getLastDoneFormalRecordByExerciseType fail")
            return nil
        }
    }
}