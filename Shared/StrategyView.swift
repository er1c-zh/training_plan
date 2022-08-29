//
// Created by eric on 2022/8/29.
//

import Foundation
import SwiftUI

struct StrategyView: View {
    @State private var strategy: Training = Training.getStrategy()
    @State private var data: Training.Data = Training.getStrategy().data
    @State private var isEditing: Bool = false
    @State private var refreshSwitch: Bool = false

    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("max_weight", comment: "")), content: {
                ForEach($data.recordList) { $r in
                    HStack {
                        Text(String(format: "%@", ExerciseType.descByVal(val: r.exerciseType)))
                        Spacer()
                        if !isEditing {
                            Text(String(format: "%.1f", r.weight))
                        } else {
                            // TODO limit to .5
                            TextField("", value: $r.weight, format: .number.precision(.fractionLength(1)))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                        }
                        Text(NSLocalizedString("weight_kg", comment: ""))
                    }
                }
            })
        }
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
