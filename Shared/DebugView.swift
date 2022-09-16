//
// Created by eric on 2022/8/28.
//

import SwiftUI

struct DebugView : View {
    @State private var trigger: Bool = false
    var body : some View {
        List {
            Section("record") {
                Button("clean", action: {
                    for r in Record.getRecordListExceptTemplate() {
                        GlobalInst.GetContext().delete(r)
                    }
                    GlobalInst.SaveContext()
                })
                ForEach(Record.getRecordListExceptTemplate()) { r in
                    Text(String(format: "%ld, %d", r.recordID, r.exerciseType))
                            .onTapGesture {
                                GlobalInst.logger.info("\(r)")
                            }
                }
            }
            Section("Training") {
                ForEach(Training.getTrainingList()) { t in
                    Text(String(format: "%ld-status: %d", t.trainingID, t.status))
                            .onTapGesture {
                                GlobalInst.logger.info("\(t)")
                            }
                }
                NavigationLink(destination: TrainingEditorView(training: Training.getDoingTraining())) {
                    Text(NSLocalizedString("create_training", comment: ""))
                            .frame(width: GlobalInst.GetBtnSize(), height: GlobalInst.GetBtnSize())
                            .foregroundColor(Color.init(UIColor.systemBackground))
                            .background(GlobalInst.green)
                            .clipShape(Circle())
                            .font(.title2.bold())
                }
            }
        }
                .navigationTitle("Debug tools")
                .navigationBarTitleDisplayMode(.inline)
                .contentShape(Rectangle())
    }
}
