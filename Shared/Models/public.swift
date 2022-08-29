//
// Created by eric on 2022/8/6.
//

import Foundation
import os
import CoreData

struct Global {
    let logger = Logger()
    let config = Config(
            Padding: 48,
            WidthInputSuffix: 36,
            WeightUnit: "kg"
    )
}

extension Global {
    // CoreData
    func GetContext() -> NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    func SaveContext() {
        do {
            try GetContext().save()
        } catch {
            fatalError()
        }
    }

    func GetMillisecondTimestamp() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000000)
    }

    // common
    func GetFont() {

    }
}

struct Config {
    // UI
    var Padding: Double
    var WidthInputSuffix: Double

    // 业务相关
    var WeightUnit: String
}

let GlobalInst = Global()
