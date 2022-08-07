//
// Created by eric on 2022/8/6.
//

import Foundation
import os

struct Global {
    let logger = Logger()
    let config = Config(Padding: 48)
}

struct Config {
    var Padding: Double
}

let GlobalInst = Global()
