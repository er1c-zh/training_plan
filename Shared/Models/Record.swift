//
// Created by eric on 2022/8/27.
//

import Foundation
import CoreData

extension Record {
    struct Data : Identifiable {
        var id: Int64 = Int64(Date().timeIntervalSince1970) * 1000
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

        GlobalInst.SaveContext()
    }

    static func getRecordListByRecordID(recordID: Int64) -> Record? {
        let fr = NSFetchRequest<Record>()
        fr.entity = Record.entity()
        fr.predicate = NSPredicate(format: "recordID == %@", recordID)
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.startTimestamp, ascending: true),
            NSSortDescriptor(keyPath: \Record.order, ascending: true)
        ]
        do {
            let context = PersistenceController.shared.container.viewContext
            let result = try context.fetch(fr)
            return result.first
        } catch {
            GlobalInst.logger.error("getRecordListByRecordID fail")
            return nil
        }
    }
}