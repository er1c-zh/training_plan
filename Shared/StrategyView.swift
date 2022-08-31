//
// Created by eric on 2022/8/29.
//

import Foundation
import SwiftUI
import Combine

struct PlateCfg: Identifiable {
    var id: Double {
        weight
    }
    var weight: Double
    var count: Int
}

struct StrategyView: View {
    @State private var strategy: Training = Training.getStrategy()
    @State private var data: Training.Data = Training.getStrategy().data
    @State private var isEditing: Bool = false
    @State private var refreshSwitch: Bool = false

    @State private var listWeightOfPlate: [PlateCfg] = getListWeightOfPlate()
    @State private var isCreatingNewPlate: Bool = false
    @State private var plateCfgCreatingWeight: Double = 0

    private func saveListWeightOfPlate() {
        var l: [String] = []
        for item in listWeightOfPlate {
            l.append(String(format: "%.2f,%d", item.weight, item.count))
        }
        GlobalInst.logger.info("getListWeightOfPlate: \(l)")
        UserDefaults.standard.set(l, forKey: "weight_of_plate")
    }

    static private func getListWeightOfPlate() -> [PlateCfg] {
        let untyped = UserDefaults.standard.stringArray(forKey: "weight_of_plate")
        if untyped == nil {
            return []
        }
        GlobalInst.logger.info("getListWeightOfPlate: \(untyped!)")
        var l: [PlateCfg] = []
        for item in untyped! {
            let tmp = item.split(separator: ",")
            if tmp.count != 2 {
                continue
            }
            let weight = Double(tmp[0])
            let count = Int(tmp[1])
            if weight == nil || count == nil {
                GlobalInst.logger.info("getListWeightOfPlate \(tmp[0]) \(tmp[1])")
                continue
            }
            GlobalInst.logger.info("==getListWeightOfPlate \(tmp[0]) \(tmp[1])")
            l.append(PlateCfg(weight: weight!, count: count!))
        }
        GlobalInst.logger.info("getListWeightOfPlate: \(l)")
        return l
    }


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
                ForEach($listWeightOfPlate) { $t in
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
                                listWeightOfPlate.remove(atOffsets: indies)
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
                                                 listWeightOfPlate.append(PlateCfg(weight: plateCfgCreatingWeight, count: 0))
                                                 listWeightOfPlate.sort(by: { $0.weight < $1.weight })
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
                            saveListWeightOfPlate()
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
