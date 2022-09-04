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
