//
// Created by eric on 2022/9/12.
//

import Foundation
import SwiftUI

struct StatisticView : View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Training.trainingID, ascending: false)],
            predicate: NSPredicate(format: "status == %d || status == %d", RecordStatus.statusDoing.rawValue, RecordStatus.statusDone.rawValue))
    private var trainingList : FetchedResults<Training>
    @State var trainingIDTapped : Int64 = 0
    @State var refreshTrigger : Bool = true

    var body : some View {
        List {
            Section(NSLocalizedString("title_record", comment: "")) {
                ForEach(trainingList) { r in
                    StatisticRowView(training: r, selectedTrainingID: $trainingIDTapped)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    if trainingIDTapped == r.trainingID {
                                        trainingIDTapped = 0
                                    } else {
                                        trainingIDTapped = r.trainingID
                                    }
                                }
                            }
                }
            }
        }
                .navigationBarTitle(NSLocalizedString("statistic_title", comment: ""), displayMode: .inline)
    }

}

struct StatisticRowView : View {
    @ObservedObject var training : Training
    @Binding var selectedTrainingID: Int64

    var body : some View {
        VStack {
            HStack {
                Text(getDate())
                Spacer()
                if training.status == RecordStatus.statusDoing.rawValue {
                    Text(NSLocalizedString("title_doing", comment: ""))
                }
            }
            Spacer()
            if selectedTrainingID != training.trainingID {
                HStack {
                    Spacer()
                    ForEach(getExerciseList()) { et in
                        Text(et.Desc())
                                .font(.system(.footnote))
                                .padding(2)
                                .background(RoundedRectangle(cornerRadius: 4).stroke())
                                .foregroundColor(Color.init(UIColor.secondaryLabel))
                    }
                }
            }
            if selectedTrainingID == training.trainingID && training.recordList != nil {
                ForEach(training.recordList!) { r in
                    StatisticRecordRowView(r: r)
                }
            }
        }
                .padding(4)
    }

    private func getExerciseList() -> [ExerciseType] {
        var result : [ExerciseType] = []
        var set : [ExerciseType: Bool] = [:]
        if let rl = training.recordList {
            for r in rl {
                let et = ExerciseType.init(rawValue: r.exerciseType)
                if let et = et {
                    if set[et] != nil {
                        continue
                    }
                    result.append(et)
                    set[et] = true
                }
            }
        }
        return result
    }

    private func getDate() -> String {
        var s = "-"
        if let rl = training.recordList {
            for r in rl {
                if r.startTimestamp != 0 {
                    let date = Date.init(timeIntervalSince1970: TimeInterval(r.startTimestamp))
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd"
                    s = f.string(from: date)
                    break
                }
            }
        }
        return s
    }
}

struct StatisticRecordRowView : View {
    @ObservedObject var r : Record

    var body: some View {
        VStack {
            HStack {
                // TODO 计算每一项最长的，填充到等宽
                Text(format())
                Spacer()
                Text(getDateString())
            }
                    .font(.system(.footnote).monospaced())
        }
    }

    private func getDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"

        var from = "-"
        var to = "-"

        if r.startTimestamp != 0 {
            from = f.string(from: Date.init(timeIntervalSince1970: TimeInterval(r.startTimestamp)))
        }
        if r.finishTimestamp != 0 {
            to = f.string(from: Date.init(timeIntervalSince1970: TimeInterval(r.finishTimestamp)))
        }

        if from == "-" && to == "-" {
            return "-"
        }
        return String(format: "%@ +%d%@", from, r.finishTimestamp - r.startTimestamp, NSLocalizedString("rest_between_sets_unit", comment: ""))
    }

    private func format() -> String {
        let tmp = ExerciseType.descByVal(val: r.exerciseType)
        return String(format: "%@ %.1fkg * %d", tmp, r.weight, r.rep)
    }
}
