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
    let red = Color.init("eRed")

    // global counter
    var counter: Int64
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

    mutating func GetAutoIncrementID() -> Int64 {
        let tmp = counter
        counter = counter + 1
        return tmp
    }

    // common
    func GetFont() -> Font {
        Font.system(.body).monospaced()
    }
    func GetBtnSize() -> CGFloat {
        96
    }
}

struct Config {
    // UI
    var Padding: Double
    var WidthInputSuffix: Double

    // 业务相关
    var WeightUnit: String
}

var GlobalInst = Global(counter: Int64(Date().timeIntervalSince1970 * 1000000))
