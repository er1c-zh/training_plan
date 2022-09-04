//
// Created by eric on 2022/9/4.
//

import Foundation
import SwiftUI
import Combine

struct TrainingPreviewView: View {
    @State var data: Training.Data

    var body: some View {
        VStack {
            ForEach(data.recordListGroupByExerciseType) { rl in
                TrainingPreviewRowView(row: rl.Data)
            }
        }
                .cornerRadius(20) /// make the background rounded
                .overlay( /// apply a rounded border
                        RoundedRectangle(cornerRadius: 20)
                                .stroke(.quaternary, lineWidth: 1)
                )
    }
}

struct TrainingPreviewRowView: View {
    @State var row: [Record.Data]
    var body: some View {
        VStack{
            Spacer().frame(height: 16)
            HStack {
                Spacer()
                Text(formatTitle())
                Spacer()
                Spacer()
                Spacer()
                Text(formatSuffix())
                Spacer()
            }
            Spacer().frame(height: 16)
        }
                .font(GlobalInst.GetFont())
    }

    private func formatTitle() -> String {
        let tmp = ExerciseType.descByVal(val: row.first!.exerciseType)
        return tmp
    }

    private func formatSuffix() -> String {
        var maxWeight: Double = 0
        for r in row {
            if r.weight > maxWeight {
                maxWeight = r.weight
            }
        }
        return String(format: "%.1f%@", maxWeight, NSLocalizedString("weight_kg", comment: ""))
    }
}

struct TrainingView: View {
    @ObservedObject var training: Training
    @State private var refresh: Bool = false

    private func getCurRecordIdx() -> Int {
        if let l = training.recordList {
            var i = 0
            GlobalInst.logger.info("recordList.len \(l.count)")
            while i < l.count {
                GlobalInst.logger.info("recordList[\(i)] = \(l[i].status)")
                if l[i].status <= RecordStatus.statusDoing.rawValue {
                    return i
                }
                i += 1
            }
        }
        return -1
    }

    var body: some View {
        VStack {
            if getCurRecordIdx() == -1 {
                Text("done")
            } else {
                Spacer()
                TrainingCardView(record: training.recordList![getCurRecordIdx()])
                Spacer()
                HStack {
                    if training.recordList![getCurRecordIdx()].status == RecordStatus.statusInit.rawValue {
                        Button(action: {
                            let i = getCurRecordIdx()
                            training.recordList![i].status = Int16(RecordStatus.statusDoing.rawValue)
                            training.recordList![i].startTimestamp = Int64(Date().timeIntervalSince1970)
                            GlobalInst.SaveContext()
                            withAnimation {
                                refresh.toggle()
                            }
                        }) {
                            Text(NSLocalizedString("start_training", comment: ""))
                                    .frame(width: 72, height: 72)
                                    .foregroundColor(Color.white)
                                    .background(Color.green)
                                    .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            let i = getCurRecordIdx()
                            training.recordList![i].status = Int16(RecordStatus.statusDone.rawValue)
                            training.recordList![i].finishTimestamp = Int64(Date().timeIntervalSince1970)
                            GlobalInst.SaveContext()
                            withAnimation {
                                refresh.toggle()
                            }
                        }) {
                            Text(NSLocalizedString("finish_record", comment: ""))
                                    .frame(width: 72, height: 72)
                                    .foregroundColor(Color.white)
                                    .background(Color.green)
                                    .clipShape(Circle())
                        }
                    }
                }
                Spacer()
            }
        }
                .padding(32)
    }
}

struct TrainingCardView: View {
    @State var record: Record
    var body: some View {
        VStack {
            HStack{
                Text(ExerciseType.descByVal(val: record.exerciseType))
                        .font(.title)
                Spacer()
            }
            Spacer().frame(height: 32)
            HStack {
                Text(formatDetail()).font(GlobalInst.GetFont())
                Spacer()
            }
        }
    }

    private func formatDetail() -> String {
        String(format: "%.1f%@ * %d", record.weight, NSLocalizedString("weight_kg", comment: ""), record.rep)
    }
}
