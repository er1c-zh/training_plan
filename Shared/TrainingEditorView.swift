//
// Created by eric on 2022/8/27.
//

import Foundation
import CoreData
import Combine
import SwiftUI

struct TrainingEditorView: View {
    @State private var data: Training.Data = Training.Data(recordList: [])
    @State private var recordData: Record.Data = Record.Data()
    @State private var isEditing: Bool = false
    @State private var idIsEditing: Int64 = 0

    var body: some View {
        List {
            ForEach($data.recordList) { $r in
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
                            data.recordList.remove(atOffsets: indexSet)
                        }
                    }
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
        }
                .navigationBarTitle(LocalizedStringKey("create_training"))
                .navigationBarItems(trailing: Button(NSLocalizedString("save", comment: "")) {
                    let training = Training(context: GlobalInst.GetContext())
                    training.trainingID = Int64(NSDate().timeIntervalSince1970)
                    GlobalInst.logger.info("save new(\(training.trainingID)) training (\(training))")
                    training.status = Training.Status.statusDoing.rawValue
                    GlobalInst.logger.info("save new training: after set status")
                    training.update(from: data)
                    GlobalInst.logger.info("save new training: after update")
                    GlobalInst.logger.info("save new(\(training.trainingID)) training (\(training))")
                    GlobalInst.SaveContext()
                })
                .sheet(isPresented: $isEditing) {
                    NavigationView {
                        RecordEditorView(r: $recordData)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel") {
                                            isEditing = false
                                        }
                                    }
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Done") {
                                            withAnimation {
                                                for (idx, r) in data.recordList.enumerated() {
                                                    if r.id == recordData.id {
                                                        data.recordList[idx] = recordData
                                                        break
                                                    }
                                                }
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
                Text(format()).font(getFont())
                Spacer()
                Text(String(format: "%ds", r.restInSec)).font(getFont())
            }
        }
    }

    private func format() -> String {
        let tmp = ExerciseType.descByVal(val: r.exerciseType)
        GlobalInst.logger.info("RecordRowView format \(tmp)")
        return String(format: "%@ %.1fkg * %d", tmp, r.weight, r.rep)
    }

    private func getFont() -> Font {
        Font.system(size: 16).monospaced()
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
                }.sheet(isPresented: $isPickingExerciseType) {
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
                        Button(action: { if r.rep > 0 {r.rep -= 1} }) {
                            Label("", systemImage: "minus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                        Button(action: { r.rep += 1 }) {
                            Label("", systemImage: "plus.circle")
                        }
                                .buttonStyle(BorderlessButtonStyle())
                    }
                    HStack {
                        Text(NSLocalizedString("rest_between_intervals", comment: ""))
                        Spacer()
                        Text(String(format: "%d", r.restInSec))
                        Text(NSLocalizedString("rest_between_intervals_unit", comment: ""))
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

struct ExerciseTypePickerView : View {
    @Binding var r: ExerciseType
    var Done : () -> ()
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
