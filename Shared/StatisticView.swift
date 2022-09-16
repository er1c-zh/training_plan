//
// Created by eric on 2022/9/12.
//

import Foundation
import SwiftUI

struct StatisticView : View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Training.trainingID, ascending: false)],
            predicate: NSPredicate(format: "status == %d || status == %d", RecordStatus.statusDoing.rawValue, RecordStatus.statusDone.rawValue))
    private var trainingList : FetchedResults<Training>

    var body : some View {
        List {
            Section(NSLocalizedString("title_record", comment: "")) {
                ForEach(trainingList) { t in
                    NavigationLink(destination: StatisticTrainingDetailView(t: t)) {
                        StatisticRowView(training: t)
                    }
                }
                        .onDelete { indies in
                            withAnimation {
                                for i in indies {
                                    trainingList[i].status = Int16(RecordStatus.statusDeleted.rawValue)
                                    for r in trainingList[i].recordList! {
                                        r.status = Int16(RecordStatus.statusDeleted.rawValue)
                                    }
                                }
                                GlobalInst.SaveContext()
                            }
                        }
            }
        }
                .navigationBarTitle(NSLocalizedString("statistic_title", comment: ""), displayMode: .inline)
    }

}

struct StatisticRowView : View {
    @ObservedObject var training : Training

    var body : some View {
        VStack {
            HStack {
                if training.status == RecordStatus.statusDoing.rawValue {
                    Text(NSLocalizedString("title_doing", comment: ""))
                } else {
                    Text(getDate())
                }
                Spacer()
                ForEach(getExerciseList()) { et in
                    ExerciseLabel(text: et.Desc())
                }
            }
            // if selected {
            //     ForEach(getGroupedRecord()) { g in
            //         HStack {
            //             ExerciseLabel(text: g.et.Desc())
            //             Spacer()
            //         }
            //         ForEach(g.data) { r in
            //             StatisticRecordRowView(r: r)
            //         }
            //     }
            // }
        }
                .padding(4)
                .contentShape(Rectangle())
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

struct StatisticTrainingDetailView : View {
    @ObservedObject var t : Training
    var body : some View {
        List {
            ForEach(getGroupedRecord()) { g in
                Section(g.et.Desc()) {
                    ForEach(g.data) { r in
                        StatisticRecordRowView(r: r)
                    }
                }
            }
        }
    }

    private func getGroupedRecord() -> [Training.RecordGroup] {
        t.getGroupedRecord()
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
        return String(format: "%d%@ %@", r.finishTimestamp - r.startTimestamp, NSLocalizedString("rest_between_sets_unit", comment: ""), from)
    }

    private func format() -> String {
        var suf = " "
        if r.weight < 100 {
            suf = "  "
        }
        return String(format: "%.1fkg%@ *   %d", r.weight, suf, r.rep)
    }
}

struct ExerciseLabel: View {
    @State var text: String
    var body : some View {
        Text(text)
                .font(.system(.footnote))
                .padding(2)
                .background(RoundedRectangle(cornerRadius: 4).stroke())
                .foregroundColor(Color.init(UIColor.secondaryLabel))
    }
}
