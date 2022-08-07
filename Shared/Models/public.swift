//
// Created by eric on 2022/8/6.
//

import Foundation
import os

struct Global {
    let logger = Logger()
    let config = Config(
            Padding: 48,
            WidthInputSuffix: 36,
            WeightUnit: "kg"
    )
}

struct Config {
    // UI
    var Padding: Double
    var WidthInputSuffix: Double

    // 业务相关
    var WeightUnit: String
}

let GlobalInst = Global()
