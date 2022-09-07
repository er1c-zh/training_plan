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
    @State private var order: Int
    @State private var status: Int
    @State private var record: Record
    @State private var restSecondTotal: Int64 = 1
    @State private var restSecondPast: Int64 = 1
    @State private var restTicker: Timer?

    @State private var preIdx: Int
    @State private var preRecord: Record

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
        if o != 0 {
            if o == -1 {
                let idx = training.recordList == nil ? -1 : training.recordList!.count - 1
                _preIdx = State<Int>.init(initialValue: idx)
                _preRecord = State<Record>.init(initialValue: idx >= 0 ? training.recordList![idx] : Record())
            } else {
                _preIdx = State<Int>.init(initialValue: o - 1)
                _preRecord = State<Record>.init(initialValue: training.recordList![o - 1])
            }
        } else {
            _preIdx = State<Int>.init(initialValue: -1)
            _preRecord = State<Record>.init(initialValue: Record())
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

    func restString() -> String {
        if restSecondPast >= restSecondTotal {
            return NSLocalizedString("start_record", comment: "")
        }
        let s = restSecondTotal - restSecondPast
        return String(format: "%ld′%02ld″", s / 60, s % 60)
    }

    var body: some View {
        VStack {
            if order == -1 {
                Text("done")
            } else {
                if preIdx != -1 {
                    TrainingCardView(idx: $preIdx, record: preRecord, isPrimary: false)
                    Spacer().frame(height: 16)
                    HStack {
                        Spacer()
                        Button(action: {
                            if preRecord.weight > 0 {
                                withAnimation {
                                    preRecord.weight -= 0.5
                                    GlobalInst.SaveContext()
                                }
                            }
                        }) {
                            Image(systemName: "minus.circle")
                        }
                        Text(NSLocalizedString("weight", comment: ""))
                        Button(action: {
                            withAnimation {
                                preRecord.weight += 0.5
                                GlobalInst.SaveContext()
                            }
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        Spacer()
                        Button(action: {
                            if preRecord.rep > 0 {
                                withAnimation {
                                    preRecord.rep -= -1
                                    GlobalInst.SaveContext()
                                }
                            }
                        }) {
                            Image(systemName: "minus.circle")
                        }
                        Text(NSLocalizedString("rep", comment: ""))
                        Button(action: {
                            withAnimation {
                                preRecord.rep += 1
                                GlobalInst.SaveContext()
                            }
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                            .foregroundColor(Color.secondary)
                } else {
                    TrainingCardView(idx: $order, record: record, isPrimary: false)
                            .mask(Path().fill())
                    // placeholder
                    Spacer().frame(height: 16)
                    HStack {
                        Text("placeholder")
                                .mask(Path().fill())
                    }
                }
                Spacer()
                TrainingCardView(idx: $order, record: record, isPrimary: true)
                Spacer().frame(height: 16)
                HStack {
                    Spacer()
                    Button(action: {
                        if record.weight > 0 {
                            withAnimation {
                                record.weight -= 0.5
                                GlobalInst.SaveContext()
                            }
                        }
                    }) {
                        Image(systemName: "minus.circle")
                    }
                    Text(NSLocalizedString("weight", comment: ""))
                    Button(action: {
                        withAnimation {
                            record.weight += 0.5
                            GlobalInst.SaveContext()
                        }
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    Spacer()
                    Button(action: {
                        if record.rep > 0 {
                            withAnimation {
                                record.rep -= -1
                                GlobalInst.SaveContext()
                            }
                        }
                    }) {
                        Image(systemName: "minus.circle")
                    }
                    Text(NSLocalizedString("rep", comment: ""))
                    Button(action: {
                        withAnimation {
                            record.rep += 1
                            GlobalInst.SaveContext()
                        }
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
                        .foregroundColor(Color.secondary)
                Spacer()
                HStack {
                    Spacer()
                    // timer short cut
                    Button(action: {
                        if restSecondTotal <= restSecondPast {
                            restSecondTotal = 15
                            restSecondPast = 0
                            restTicker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                                withAnimation {
                                    restSecondPast += 1
                                    if restSecondPast >= restSecondTotal {
                                        restTicker?.invalidate()
                                    }
                                }
                            })
                        } else {
                            restSecondTotal += 15
                        }
                    }) {
                        Circle()
                                .stroke(Color.green)
                                .frame(width: TrainingView.btnSize, height: TrainingView.btnSize)
                                .overlay(Text("+15s")
                                        .font(.system(.title2).bold().monospaced())
                                        .foregroundColor(Color.green))
                    }
                    Spacer()
                    if status == RecordStatus.statusInit.rawValue {
                        Button(action: {
                            withAnimation {
                                training.recordList![order].status = Int16(RecordStatus.statusDoing.rawValue)
                                training.recordList![order].startTimestamp = Int64(Date().timeIntervalSince1970)
                                training.versionID += 1
                                GlobalInst.SaveContext()
                                restTicker?.invalidate()
                            }
                        }) {
                            ZStack {
                                Circle()
                                        .fill(Color.green)
                                        .frame(width: TrainingView.btnSize, height: TrainingView.btnSize)
                                        .overlay(Text(restString())
                                                .font(.system(.title2).bold().monospaced())
                                                .foregroundColor(Color.white))
                                        .mask(TimerBtnMask(total: restSecondTotal, cur: restSecondPast, clockwise: false).fill(Color.white))
                                Circle()
                                        .stroke(Color.green, lineWidth: TrainingView.btnBorder)
                                        .frame(width: TrainingView.btnSize, height: TrainingView.btnSize)
                                        .overlay(Text(restString())
                                                .font(.system(.title2).bold().monospaced())
                                                .foregroundColor(Color.green))
                                        .mask(TimerBtnMask(total: restSecondTotal, cur: restSecondTotal - restSecondPast, clockwise: true).fill(Color.white))
                            }
                        }
                    } else {
                            Button(action: {
                                withAnimation {
                                    let oldOrder = order
                                    training.recordList![order].status = Int16(RecordStatus.statusDone.rawValue)
                                    training.recordList![order].finishTimestamp = Int64(Date().timeIntervalSince1970)
                                    training.versionID += 1
                                    GlobalInst.SaveContext()
                                    // FIXME Refreshing rest second should wait didChange listener finished its work.
                                    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { _ in
                                        if oldOrder == order || order == -1 {
                                            return
                                        }
                                        withAnimation {
                                            preIdx = oldOrder
                                            preRecord = training.recordList![preIdx]
                                            restSecondTotal = record.restInSec
                                            restSecondPast = 0
                                            restTicker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                                                withAnimation {
                                                    restSecondPast += 1
                                                    if restSecondPast >= restSecondTotal {
                                                        restTicker?.invalidate()
                                                    }
                                                }
                                            })
                                        }
                                    })
                                }
                            }) {
                                Circle()
                                        .stroke(Color.green, lineWidth: TrainingView.btnBorder) // FIXME mask导致相同粗细但是展示不同
                                        .frame(width: TrainingView.btnSize, height: TrainingView.btnSize)
                                        .overlay(Text(NSLocalizedString("finish_record", comment: ""))
                                                .font(.system(.title2).bold())
                                                .foregroundColor(Color.green))
                            }
                    }
                    Spacer()
                }
                Spacer()
                // ProgressBar
                ProgressView(value: Double(order + 1) / Double(training.recordList!.count)) {
                    Text(String(format: "%d/%d", order + 1, training.recordList!.count))
                            .foregroundColor(Color.secondary)
                }
                        .tint(Color.green)
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

    static let btnSize: CGFloat = 96
    static let btnBorder: CGFloat = 4
}

struct TimerBtnMask: Shape {
    let total: Int64
    let cur: Int64
    let clockwise: Bool

    private var degreesPerSecond: Double {
        360.0 / Double(total)
    }

    private var startAngle: Angle {
        Angle(degrees: -90)
    }
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerSecond * Double(cur) * (clockwise ? -1 : 1))
    }

    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height)
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let start = CGPoint(x: rect.midX, y: 0)
        return Path { path in
            path.move(to: start)
            path.addLine(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            path.addLine(to: center)
        }
    }
}

struct TrainingCardView: View {
    @Binding var idx: Int
    @ObservedObject var record: Record
    @State var isPrimary: Bool
    var body: some View {
        VStack {
            if isPrimary {
                HStack {
                    Text("No. \(idx + 1) \(ExerciseType.descByVal(val: record.exerciseType))")
                            .font(.title)
                    Spacer()
                }
                Spacer().frame(height: 32)
                HStack {
                    Text(formatDetail()).font(GlobalInst.GetFont())
                    Spacer()
                    Text(formatDetailSuffix()).font(GlobalInst.GetFont())
                }
            } else {
                HStack {
                    Text("No. \(idx + 1) \(ExerciseType.descByVal(val: record.exerciseType))")
                    Spacer()
                    Text(formatDetail()).font(GlobalInst.GetFont())
                }
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
