//
// Created by eric on 2022/8/6.
//

import Foundation
import os
import CoreData
import SwiftUI

struct Global {
    let logger = Logger()
    let config = Config(
            Padding: 48,
            WidthInputSuffix: 36,
            WeightUnit: "kg"
    )

    // theme
    let green = Color.init("eGreen")
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

    func GetTimestamp() -> Int64 {
        Int64(Date().timeIntervalSince1970)
    }

    func GetNanosecondTimestamp() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000000)
    }

    // common
    func GetFont() -> Font {
        Font.system(.body).monospaced()
    }
    func GetBtnSize() -> CGFloat {
        return 96
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
