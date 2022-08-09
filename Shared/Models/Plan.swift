//
// Created by eric on 2022/8/6.
//

import Foundation

struct Plan: Identifiable {
    let id: UUID
    var Name: String
    var GroupList: [PlanGroupItem]

    init(id: UUID = UUID(), Name: String, GroupList: [PlanGroupItem]) {
        self.id = id
        self.Name = Name
        self.GroupList = GroupList
    }
}

extension Plan {
    struct Data {
        var Name: String = ""
        var GroupList: [PlanGroupItem] = []
    }

    var data: Data {
        Data(Name: Name, GroupList: GroupList)
    }

    mutating func update(from data: Data) {
        Name = data.Name
        GroupList = data.GroupList
    }
}


struct ExerciseType: Identifiable {
    var id: String
}

extension ExerciseType {
    struct Data {
        var id: String = ""
    }

    mutating func update(from data: Data) {
        id = data.id
    }

    static func GetExerciseType() -> [ExerciseType] {
        [
            ExerciseType(id: "深蹲"),
            ExerciseType(id: "硬拉"),
            ExerciseType(id: "推举"),
            ExerciseType(id: "卧推"),
        ]
    }

    static func Nil() -> ExerciseType {
        ExerciseType(id: "")
    }

    static func WaitEdit() -> ExerciseType {
        ExerciseType(id: "WaitEdit")
    }
}

struct PlanGroupItem: Identifiable {
    let id: UUID
    var Exercise: ExerciseType
    var ItemList: [PlanItem]

    init(id: UUID = UUID(), Group: ExerciseType, ItemList: [PlanItem]) {
        self.id = id
        self.Exercise = Group
        self.ItemList = ItemList
    }
}

extension PlanGroupItem {
    struct Data {
        var Exercise: ExerciseType = ExerciseType(id: "")
        var ItemList: [PlanItem] = []
    }

    var data: Data {
        Data(Exercise: Exercise, ItemList: ItemList)
    }

    mutating func update(from data: Data) {
        Exercise = data.Exercise
        ItemList = data.ItemList
    }
}

struct PlanItem: Identifiable {
    let id = UUID()
    var Weight: Double
    var CountPerRound, CntOfRound: Int64
    var IntervalInSeconds: Int64
}

extension PlanItem {
    struct Data {
        var Weight: Double = 0
        var CountPerRound: Int64 = 0
        var CntOfRound: Int64 = 0
        var IntervalInSeconds: Int64 = 0
    }

    var data: Data {
        Data(Weight: Weight, CountPerRound: CountPerRound, CntOfRound: CntOfRound, IntervalInSeconds: IntervalInSeconds)
    }

    mutating func update(from data: Data) {
        Weight = data.Weight
        CountPerRound = data.CountPerRound
        CntOfRound = data.CntOfRound
        IntervalInSeconds = data.IntervalInSeconds
    }

}
