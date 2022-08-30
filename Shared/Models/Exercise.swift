//
//  Exercise.swift
//  training
//
//  Created by eric on 2022/8/27.
//

import Foundation

enum ExerciseType : Int16 {
    case Unknown = 0
    case BenchPress = 1
    case Squat = 2
    case Deadlift = 3
    case MilitaryPress = 4
    case BentOverRow = 5
    case PowerClean = 6
}

extension ExerciseType : Identifiable {
    var id : Self {self}
    static let descMap: [ExerciseType: String] = [
        .BenchPress: NSLocalizedString("bench_press", comment: ""),
        .Squat: NSLocalizedString("squat", comment: ""),
        .Deadlift: NSLocalizedString("deadlift", comment: ""),
        .MilitaryPress: NSLocalizedString("military_press", comment: ""),
        .BentOverRow: NSLocalizedString("bent_over_row", comment: ""),
        .PowerClean: NSLocalizedString("power_clean", comment: "")
    ]

    static func getAllExerciseType() -> [ExerciseType] {
        [.BenchPress, .Squat, .Deadlift, .MilitaryPress, .BentOverRow, .PowerClean]
    }

    static func descByVal(val: Int16) -> String {
        let e = ExerciseType(rawValue: val)
        var et: ExerciseType
        if e != nil {
            et = e!
        } else {
            et = ExerciseType.Unknown
        }
        return et.Desc()
    }

    func Desc() -> String {
        if let v = ExerciseType.descMap[self] {
            return v
        } else {
            return NSLocalizedString("unknown_exercise_type", comment: "")
        }
    }
}
