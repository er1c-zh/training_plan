//
// Created by eric on 2022/8/6.
//

import Foundation

struct Plan : Identifiable {
    let id = UUID()
    var Name : String
    var GroupList : [PlanGroupItem]
}

struct PlanFactory {
    public func New() -> Plan {
        Plan(Name: "", GroupList: [])
    }
}

struct PlanGroup {
    var Name: String
}

struct PlanGroupItem : Identifiable {
    let id = UUID()
    var Group: PlanGroup
    var ItemList : [PlanItem]
}

struct PlanItem : Identifiable {
    let id = UUID()
    var Weight, CountPerRound, CntOfRound: Int64
    var IntervalInSeconds: Int64
}