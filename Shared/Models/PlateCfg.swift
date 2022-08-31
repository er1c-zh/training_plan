//
// Created by eric on 2022/8/31.
//

import Foundation

struct PlateCfg: Identifiable {
    var id: Double {
        weight
    }
    var weight: Double
    var count: Int


    static public func saveList(list: [PlateCfg]) {
        var l: [String] = []
        for item in list {
            l.append(String(format: "%.2f,%d", item.weight, item.count))
        }
        UserDefaults.standard.set(l, forKey: "weight_of_plate")
    }

    static public func getList() -> [PlateCfg] {
        let untyped = UserDefaults.standard.stringArray(forKey: "weight_of_plate")
        if untyped == nil {
            return []
        }
        var l: [PlateCfg] = []
        for item in untyped! {
            let tmp = item.split(separator: ",")
            if tmp.count != 2 {
                continue
            }
            let weight = Double(tmp[0])
            let count = Int(tmp[1])
            if weight == nil || count == nil {
                continue
            }
            l.append(PlateCfg(weight: weight!, count: count!))
        }
        return l
    }
}