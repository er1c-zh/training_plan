//
// Created by eric on 2022/8/31.
//

import Foundation

struct SetTag: OptionSet {
    let rawValue: Int

    // type
    static let formalSet = SetTag(rawValue: 1 << 0)
    static let warmupSet = SetTag(rawValue: 1 << 1)

    // body part to exercise
    static let upper = SetTag(rawValue: 1 << 5)
    static let lower = SetTag(rawValue: 1 << 6)

}
