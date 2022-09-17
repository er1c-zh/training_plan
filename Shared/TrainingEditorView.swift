//
// Created by eric on 2022/8/27.
//

import Foundation
import CoreData
import Combine
import SwiftUI

enum TrainingEditorViewSheetID: Identifiable {
    case exercisePicker, editor
    var id: Int {
        hashValue
    }
}

struct TrainingEditorView: View {
    @ObservedObject var training: Training
    @State private var data: Training.Data = Training.Data(recordList: [], recordListGroupByExerciseType: [])
    @State private var recordData: Record.Data = Record.Data()
    @State private var isCreating: Bool = false
    @State private var isEditing: Bool = false
    @State private var exerciseTypeListPicked: [ExerciseType.GenCfg] = []

    var body: some View {
        List {
            Section {
                Button(NSLocalizedString("add", comment: "")) {
                    withAnimation {
                        let tmp = Record.Data()
                        recordData = tmp
                        withAnimation {
                            data.recordList.append(tmp)
                            isEditing = true
                        }
                    }
                }
                Button(NSLocalizedString("init_training", comment: "")) {
                    exerciseTypeListPicked = []
                    withAnimation {
                        isCreating = true
                    }
                }
            }
            ForEach($data.recordListGroupByExerciseType) { $rl in
                Section {
                    ForEach($rl.Data) { $r in
                        RecordRowView(r: $r)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    recordData = r
                                    withAnimation {
                                        isEditing = true
                                    }
                                }
                    }
                            .onDelete { indexSet in
                                withAnimation {
                                    for i in indexSet {
                                        let r = rl.Data[i]
                                        data.recordList.removeAll(where: { d in
                                            d.id == r.id
                                        })
                                    }
                                    data.format()
                                }
                            }
                }
            }
        }
                .navigationBarTitle(LocalizedStringKey("create_training"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(NSLocalizedString("save", comment: "")) {
                    training.status = Int16(RecordStatus.statusDoing.rawValue)
                    training.update(from: data)
                    GlobalInst.SaveContext()
                })
                .sheet(isPresented: $isCreating) {
                    NavigationView {
                        MultipleExerciseTypePickerView(r: $exerciseTypeListPicked)
                                .navigationBarTitle(NSLocalizedString("init_training_title", comment: ""), displayMode: .inline)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button(NSLocalizedString("cancel", comment: "")) {
                                            isCreating = false
                                        }
                                    }
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button(NSLocalizedString("save", comment: "")) {
                                            data.recordList = Generator.gen(etList: exerciseTypeListPicked)
                                            data.format()
                                            withAnimation {
                                                isCreating = false
                                            }
                                        }
                                    }
                                }
                    }
                }
                .sheet(isPresented: $isEditing) {
                    NavigationView {
                        RecordEditorView(r: $recordData)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button(NSLocalizedString("cancel", comment: "")) {
                                            isEditing = false
                                        }
                                    }
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button(NSLocalizedString("save", comment: "")) {
                                            withAnimation {
                                                for (idx, r) in data.recordList.enumerated() {
                                                    if r.id == recordData.id {
                                                        data.recordList[idx] = recordData
                                                        break
                                                    }
                                                }
                                                data.format()
                                                isEditing = false
                                            }
                                        }
                                    }
                                }
                    }
                }
    }
}

struct RecordRowView: View {
    @Binding var r: Record.Data

    var body: some View {
        VStack {
            HStack {
                // TODO 计算每一项最长的，填充到等宽
                Text(format()).font(GlobalInst.GetFont())
                Spacer()
                Text(String(format: "%ds", r.restInSec)).font(GlobalInst.GetFont())
            }
        }
    }

    private func format() -> String {
        let tmp = ExerciseType.descByVal(val: r.exerciseType)
        return String(format: "%@ %.1fkg * %d", tmp, r.weight, r.rep)
    }
}

struct RecordEditorView: View {
    @Binding var r: Record.Data
    @State private var isPickingExerciseType: Bool = false
    @State private var pickedExerciseType: ExerciseType = ExerciseType.Unknown
    var body: some View {
        Form {
            List {
                Section(NSLocalizedString("exercise_type", comment: "")) {
                    Button(ExerciseType.descByVal(val: r.exerciseType)) {
                        withAnimation {
                            isPickingExerciseType = true
                            if let type = ExerciseType.init(rawValue: r.exerciseType) {
                                pickedExerciseType = type
                            } else {
                                pickedExerciseType = ExerciseType.Unknown
                            }
                        }
                    }
                }
                        .sheet(isPresented: $isPickingExerciseType) {
                            ExerciseTypePickerView(r: $pickedExerciseType, Done: {
                                withAnimation {
                                    r.exerciseType = pickedExerciseType.rawValue
                                    isPickingExerciseType = false
                                }
                            })
                        }
                Section(NSLocalizedString("quantity", comment: "")) {
                    HStack {
                        Text(NSLocalizedString("weight", comment: ""))
                        Spacer()
                        Text(String(format: "%.1f", r.weight))
                        Text(NSLocalizedString("weight_kg", comment: ""))
                                .frame(width: unitWidth())
                        Button(action: reduceWeight) {
                            Label("", systemImage: "minus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                        Button(action: increaseWeight) {
                            Label("", systemImage: "plus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                    }
                    HStack {
                        Text(NSLocalizedString("rep", comment: ""))
                        Spacer()
                        Text(String(format: "%d", r.rep))
                        Text(NSLocalizedString("rep_unit", comment: ""))
                                .frame(width: unitWidth())
                        Button(action: {
                            if r.rep > 0 {
                                r.rep -= 1
                            }
                        }) {
                            Label("", systemImage: "minus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                        Button(action: { r.rep += 1 }) {
                            Label("", systemImage: "plus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                    }
                    HStack {
                        Text(NSLocalizedString("rest_between_sets", comment: ""))
                        Spacer()
                        Text(String(format: "%d", r.restInSec))
                        Text(NSLocalizedString("rest_between_sets_unit", comment: ""))
                                .frame(width: unitWidth())
                        Button(action: {
                            r.restInSec -= 30
                            if r.restInSec < 0 {
                                r.restInSec = 0
                            }
                        }) {
                            Label("", systemImage: "minus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                        Button(action: { r.restInSec += 30 }) {
                            Label("", systemImage: "plus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
                .navigationBarTitleDisplayMode(.inline)
    }

    private func increaseWeight() {
        r.weight += 0.5
    }

    private func reduceWeight() {
        r.weight -= 0.5
        if r.weight <= 0 {
            r.weight = 0
        }
    }

    private func unitWidth() -> CGFloat {
        32
    }
}

struct ExerciseTypePickerView: View {
    @Binding var r: ExerciseType
    var Done: () -> ()
    var body: some View {
        List {
            ForEach(ExerciseType.getAllExerciseType()) { t in
                Button(t.Desc()) {
                    r = t
                    Done()
                }
            }
        }
    }
}

struct MultipleExerciseTypePickerView: View {
    @Binding var r: [ExerciseType.GenCfg]
    @State var list : [ExerciseType.GenCfg] =  {
        var result : [ExerciseType.GenCfg] = []
        for et in ExerciseType.getAllExerciseType() {
            result.append(ExerciseType.GenCfg(ExerciseType: et, Strategy: .progressiveOverload))
        }
        return result
    }()

    var body: some View {
        List {
            ForEach(list) { t in
                HStack {
                    Button(t.ExerciseType.Desc()) {
                        withAnimation {
                            if getIndex(e: t) >= 0 {
                                r.remove(at: getIndex(e: t))
                            } else {
                                r.append(t)
                            }
                        }
                    }
                    Spacer()
                    if getLastRecordDate(et: t.ExerciseType) != "" {
                        Text(getLastRecordDate(et: t.ExerciseType))
                                .font(.system(.footnote))
                                .padding(2)
                                .background(RoundedRectangle(cornerRadius: 4).stroke())
                                .foregroundColor(Color.init(UIColor.secondaryLabel))
                    }
                    if getIndex(e: t) >= 0 {
                        Text(String(format: "%d", getIndex(e: t) + 1))
                                .padding(4)
                                .font(.system(.body).monospaced())
                                .background(Circle().stroke())
                                .foregroundColor(Color.init(UIColor.secondaryLabel))
                        Button(action: {
                            withAnimation {
                                toggleStrategy(e: t)
                            }
                        }) {
                            Image(systemName: (t.Strategy == ExerciseType.GenerateStrategy.stayCurrentWeight) ? "arrow.forward" : "arrow.up.forward")
                                    .foregroundColor(Color.init(UIColor.secondaryLabel))
                                    .frame(width: 23)
                        }
                                .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    func toggleStrategy(e: ExerciseType.GenCfg) {
        var i = 0
        while i < list.count {
            if list[i].ExerciseType == e.ExerciseType {
                list[i].Strategy = list[i].Strategy.toggle()
            }
            i += 1
        }
        i = 0
        while i < r.count {
            if r[i].ExerciseType == e.ExerciseType {
                r[i].Strategy = r[i].Strategy.toggle()
            }
            i += 1
        }
    }

    func getIndex(e: ExerciseType.GenCfg) -> Int {
        var i = 0
        while i < r.count {
            if r[i].ExerciseType == e.ExerciseType {
                return i
            }
            i += 1
        }
        return -1
    }

    func getLastRecordDate(et: ExerciseType) -> String {
        let r = Record.getLastDoneRecordByExerciseType(et: et)
        if let r = r {
            let calendar = NSCalendar.current

            // Replace the hour (time) of both dates with 00:00
            let date1 = calendar.startOfDay(for: Date.init(timeIntervalSince1970: TimeInterval(r.startTimestamp)))
            let date2 = calendar.startOfDay(for: Date())
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            if let countOfDayFromLastRecord = components.day {
                if countOfDayFromLastRecord == 0 {
                    return "今天"
                }
                return String(format: "%d天前", countOfDayFromLastRecord)
            }
        }
        return ""
    }
}
