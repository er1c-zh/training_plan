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
                    training.status = Training.Status.statusDoing.rawValue
                    training.update(from: data)
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
                                    isPickingExerciseType = false
                                    r.exerciseType = pickedExerciseType.rawValue
                                }
                            })
                        }
            }
        }
                .navigationBarTitleDisplayMode(.inline)
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
