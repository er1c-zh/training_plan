//
// Created by eric on 2022/8/6.
//

import Foundation

struct Plan : Identifiable {
    let id : UUID
    var Name : String
    var GroupList : [PlanGroupItem]

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


struct PlanGroup {
    var Name: String
}

struct PlanGroupItem : Identifiable {
    let id : UUID
    var Group: PlanGroup
    var ItemList : [PlanItem]

    init(id: UUID = UUID(), Group: PlanGroup, ItemList: [PlanItem]) {
        self.id = id
        self.Group = Group
        self.ItemList = ItemList
    }
}

extension PlanGroupItem {
    struct Data {
        var Group: PlanGroup = PlanGroup(Name: "")
        var ItemList : [PlanItem] = []
    }
    var data: Data {
        Data(Group: Group, ItemList: ItemList)
    }
}

struct PlanItem : Identifiable {
    let id = UUID()
    var Weight, CountPerRound, CntOfRound: Int64
    var IntervalInSeconds: Int64
}
