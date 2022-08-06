//
// Created by eric on 2022/8/6.
//

import Foundation

struct Plan : Identifiable {
    let id = UUID()
    var Name : String
    var GroupList : [PlanGroupItem]
}

struct PlanGroupItem : Identifiable {
    let id = UUID()
    var Name : String // 卧推
    var ItemList : [PlanItem]
}

struct PlanItem : Identifiable {
    let id = UUID()
    var Weight, CountPerRound, CntOfRound: Int64
    var IntervalInSeconds: Int64
}
