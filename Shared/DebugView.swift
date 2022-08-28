//
// Created by eric on 2022/8/28.
//

import SwiftUI

struct DebugView : View {
    var body : some View {
        List {
            Section("record") {
                ForEach(Record.getRecordList()) { r in
                    Text(String(format: "%ld, %d", r.recordID, r.exerciseType))
                            .onTapGesture {
                                GlobalInst.logger.info("\(r)")
                            }
                }
            }
            Section("Training") {
                ForEach(Training.getTrainingList()) { t in
                    Text(String(format: "%d", t.trainingID))
                            .onTapGesture {
                                GlobalInst.logger.info("\(t)")
                            }
                }
            }
        }
                .navigationTitle("Debug tools")
                .navigationBarTitleDisplayMode(.inline)
                .contentShape(Rectangle())
    }
}
