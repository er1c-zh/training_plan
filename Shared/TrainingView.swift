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
    private var didChange = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)  //the publisher
    @ObservedObject var training: Training
    @State var order: Int
    @State var status: Int
    @State var record: Record

    init(training: Training) {
        self.training = training
        var o: Int = -1
        if let l = training.recordList {
            var i = 0
            while i < l.count {
                if l[i].status == RecordStatus.statusInit.rawValue ||
                           l[i].status == RecordStatus.statusDoing.rawValue {
                    o = i
                    break
                }
                i += 1
            }

        }
        _order = State<Int>.init(initialValue: o)
        if o > -1 {
            _status = State<Int>.init(initialValue: Int(training.recordList![o].status))
        } else {
            _status = State<Int>.init(initialValue: Int(RecordStatus.statusInit.rawValue))
        }
        if o > -1 {
            _record = State<Record>.init(initialValue: training.recordList![o])
        } else {
            _record = State<Record>.init(initialValue: Record())
        }
    }

    func refreshCurRecordIdx() -> Int {
        if let l = training.recordList {
            var i = 0
            while i < l.count {
                if l[i].status == RecordStatus.statusInit.rawValue ||
                           l[i].status == RecordStatus.statusDoing.rawValue {
                    return i
                }
                i += 1
            }
        }
        return -1
    }

    var body: some View {
        VStack {
            if order == -1 {
                Text("done")
            } else {
                Spacer()
                TrainingCardView(idx: $order, record: $record)
                Spacer()
                HStack {
                    if status == RecordStatus.statusInit.rawValue {
                        Button(action: {
                            withAnimation {
                                training.recordList![order].status = Int16(RecordStatus.statusDoing.rawValue)
                                training.recordList![order].startTimestamp = Int64(Date().timeIntervalSince1970)
                                training.versionID += 1
                                GlobalInst.SaveContext()
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
                            withAnimation {
                                training.recordList![order].status = Int16(RecordStatus.statusDone.rawValue)
                                training.recordList![order].finishTimestamp = Int64(Date().timeIntervalSince1970)
                                training.versionID += 1
                                GlobalInst.SaveContext()
                            }
                        }) {
                            Text(NSLocalizedString("finish_record", comment: ""))
                                    .frame(width: 72, height: 72)
                                    .foregroundColor(Color.green)
                                    .font(.system(.body).bold())
                                    .overlay(Circle().stroke(Color.green))
                        }
                    }
                }
                Spacer()
            }
        }
                .padding(32)
                .onReceive(didChange) { output in
                    withAnimation {
                        order = refreshCurRecordIdx()
                        if order > -1 {
                            status = Int(training.recordList![order].status)
                            record = training.recordList![order]
                        } else {
                            status = RecordStatus.statusInit.rawValue
                        }
                    }
                }
    }
}

struct TrainingCardView: View {
    @Binding var idx: Int
    @Binding var record: Record
    var body: some View {
        VStack {
            HStack {
                Text("No. \(idx + 1)")
                        .font(.title)
                Spacer()
            }
            HStack{
                Text(ExerciseType.descByVal(val: record.exerciseType))
                        .font(.title)
                Spacer()
            }
            Spacer().frame(height: 32)
            HStack {
                Text(formatDetail()).font(GlobalInst.GetFont())
                Spacer()
                Text(formatDetailSuffix()).font(GlobalInst.GetFont())
            }
        }
    }

    private func formatDetail() -> String {
        String(format: "%.1f%@ * %d", record.weight, NSLocalizedString("weight_kg", comment: ""), record.rep)
    }

    private func formatDetailSuffix() -> String {
        String(format: "rest: %d%@", record.restInSec, NSLocalizedString("rest_between_sets_unit", comment: ""))
    }
}
