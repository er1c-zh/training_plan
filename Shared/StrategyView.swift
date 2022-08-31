//
// Created by eric on 2022/8/29.
//

import Foundation
import SwiftUI
import Combine

struct StrategyView: View {
    @State private var strategy: Training = Training.getStrategy()
    @State private var data: Training.Data = Training.getStrategy().data
    @State private var isEditing: Bool = false
    @State private var refreshSwitch: Bool = false

    @State private var plateList: [PlateCfg] = PlateCfg.getList()
    @State private var isCreatingNewPlate: Bool = false
    @State private var plateCfgCreatingWeight: Double = 0

    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("max_weight", comment: "")), content: {
                ForEach($data.recordList) { $r in
                    HStack {
                        Text(String(format: "%@", ExerciseType.descByVal(val: r.exerciseType)))
                        Spacer()
                        if !isEditing {
                            Text(String(format: "%.0f", r.weight))
                        } else {
                            TextField("", value: $r.weight, format: .number.precision(.fractionLength(0)))
                                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                        if let textField = obj.object as? UITextField {
                                            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                        }
                                    }
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                        }
                        Text(NSLocalizedString("weight_kg", comment: ""))
                    }
                }
            })
            Section(header: Text(NSLocalizedString("title_weight_of_plate", comment: "")), content: {
                ForEach($plateList) { $t in
                    HStack {
                        Text(String(format: "%.2f", t.weight))
                        Text(NSLocalizedString("weight_kg", comment: ""))
                        Spacer()
                        if !isEditing {
                            Text(String(format: "%d", t.count))
                        } else {
                            TextField("", value: $t.count, format: .number.precision(.fractionLength(0)))
                                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                        if let textField = obj.object as? UITextField {
                                            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                        }
                                    }
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                        }
                        Text(NSLocalizedString("plate_unit", comment: ""))
                    }
                }
                        .onDelete { indies in
                            withAnimation {
                                plateList.remove(atOffsets: indies)
                            }
                        }
                if isEditing {
                    Button(NSLocalizedString("add", comment: "")) {
                        withAnimation {
                            plateCfgCreatingWeight = 0
                            isCreatingNewPlate = true
                        }
                    }
                            .sheet(isPresented: $isCreatingNewPlate, content: {
                                NavigationView {
                                    List {
                                        HStack {
                                            Text(NSLocalizedString("weight", comment: ""))
                                            Spacer()
                                            TextField("", value: $plateCfgCreatingWeight, format: .number.precision(.fractionLength(2)))
                                                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                                        if let textField = obj.object as? UITextField {
                                                            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                                        }
                                                    }
                                                    .keyboardType(.decimalPad)
                                                    .multilineTextAlignment(.trailing)
                                            Text(NSLocalizedString("weight_kg", comment: ""))
                                        }
                                    }
                                            .navigationBarTitle("创建杠铃片")
                                     .toolbar {
                                         ToolbarItem(placement: .cancellationAction) {
                                             Button("Cancel") {
                                                 withAnimation {
                                                     isCreatingNewPlate = false
                                                 }
                                             }
                                         }
                                         ToolbarItem(placement: .confirmationAction) {
                                             Button("Done") {
                                                 plateList.append(PlateCfg(weight: plateCfgCreatingWeight, count: 0))
                                                 plateList.sort(by: { $0.weight < $1.weight })
                                                 withAnimation {
                                                     isCreatingNewPlate = false
                                                 }
                                             }
                                         }
                                     }
                                }
                            })
                }
            })
        }
                .font(GlobalInst.GetFont())
                .listStyle(.insetGrouped)
                .navigationBarItems(leading: VStack {
                    if isEditing {
                        Button(NSLocalizedString("cancel", comment: "")) {
                            strategy = Training.getStrategy()
                            withAnimation {
                                data = strategy.data
                                isEditing = false
                            }
                        }
                    }
                })
                .navigationBarItems(trailing: VStack {
                    if isEditing {
                        Button(NSLocalizedString("save", comment: "")) {
                            strategy.update(from: data)
                            GlobalInst.SaveContext()
                            PlateCfg.saveList(list: plateList)
                            withAnimation {
                                isEditing = false
                            }
                        }
                    } else {
                        Button(NSLocalizedString("edit", comment: "")) {
                            withAnimation {
                                isEditing = true
                            }
                        }
                    }
                })
                .navigationBarTitle(NSLocalizedString("title_strategy", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
    }
}
