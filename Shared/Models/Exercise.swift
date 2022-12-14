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
    case SumoDeadLift = 7
}

extension ExerciseType : Identifiable {
    var id : Self {self}
    static let descMap: [ExerciseType: String] = [
        .BenchPress: NSLocalizedString("bench_press", comment: ""),
        .Squat: NSLocalizedString("squat", comment: ""),
        .Deadlift: NSLocalizedString("deadlift", comment: ""),
        .MilitaryPress: NSLocalizedString("military_press", comment: ""),
        .BentOverRow: NSLocalizedString("bent_over_row", comment: ""),
        .PowerClean: NSLocalizedString("power_clean", comment: ""),
        .SumoDeadLift: NSLocalizedString("sumo_deadlift", comment: "")
    ]

    struct Config {
        var ExerciseType: ExerciseType
        var MinWeight: Double = 0
        var CntOfWarmUp: Int = 0
        var CntOfFormal: Int = 0
    }

    enum GenerateStrategy {
        case stayCurrentWeight
        case progressiveOverload

        func toggle() -> GenerateStrategy {
            if self == .stayCurrentWeight {
                return .progressiveOverload
            } else {
                return .stayCurrentWeight
            }
        }
    }

    struct GenCfg : Identifiable {
        var id : ExerciseType { ExerciseType }

        var ExerciseType: ExerciseType
        var Strategy: GenerateStrategy
    }

    static func getAllExerciseType() -> [ExerciseType] {
        [.BenchPress, .Squat, .Deadlift, .MilitaryPress, .BentOverRow, .PowerClean, .SumoDeadLift]
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

    func MinWeight() -> Double {
        switch self {
        case .Deadlift, .SumoDeadLift:
            return 60
        default:
            return 20
        }
    }

    func countOfWarmUpSet() -> Int {
        switch self {
        case .Deadlift, .SumoDeadLift:
            return 2
        default:
            return 3
        }
    }
    func countOfFormalSet() -> Int {
        switch self {
        case .Deadlift:
            return 1
        case .SumoDeadLift:
            return 2
        case .Squat, .BenchPress:
            return 3
        default:
            return 5
        }
    }
}
