//
//  ContentView.swift
//  Shared
//
//  Created by eric on 2022/8/5.
//
//

import SwiftUI
import CoreData

struct MainView: View {
    @State private var selection = 1
    @ObservedObject private var lastTraining: Training = Training.getLastTodayTraining()
    @ObservedObject private var training: Training = Training.getDoingTraining()

    var body: some View {
        TabView(selection: $selection) {
            // 统计
            NavigationView {
                StatisticView()
            }
                    .tabItem {
                        Label("Statistic", systemImage: "chart.xyaxis.line")
                    }
                    .tag(0)

            // Today
            NavigationView {
                VStack {
                    if training.status != RecordStatus.statusInit.rawValue {
                        TrainingPreviewView(data: training.data)
                                .padding(32)
                    } else if lastTraining.status != RecordStatus.statusInit.rawValue {
                        TrainingPreviewView(data: lastTraining.data)
                                .padding(32)
                    }

                    Spacer()
                    if training.status != RecordStatus.statusDoing.rawValue && lastTraining.status == RecordStatus.statusDone.rawValue {
                        Text(NSLocalizedString("congratulations", comment: ""))
                        Spacer()
                    }
                    HStack {
                        if training.status == RecordStatus.statusDoing.rawValue {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    training.status = Int16(RecordStatus.statusInit.rawValue)
                                    if let l = training.recordList {
                                        for r in l {
                                            GlobalInst.GetContext().delete(r)
                                        }
                                    }
                                    training.recordList = nil
                                    GlobalInst.SaveContext()
                                }
                            }) {
                                Text(NSLocalizedString("del_training", comment: ""))
                                        .frame(width: GlobalInst.GetBtnSize(), height: GlobalInst.GetBtnSize())
                                        .foregroundColor(Color.init(UIColor.systemBackground))
                                        .background(GlobalInst.red)
                                        .clipShape(Circle())
                                        .font(.title2.bold())
                            }
                            Spacer()

                            Spacer()
                            NavigationLink(destination: TrainingView(training: training)) {
                                Text(getStartOrContinue())
                                        .frame(width: GlobalInst.GetBtnSize(), height: GlobalInst.GetBtnSize())
                                        .foregroundColor(Color.init(UIColor.systemBackground))
                                        .background(GlobalInst.green)
                                        .clipShape(Circle())
                                        .font(.title2.bold())
                            }
                            Spacer()
                        } else {
                            NavigationLink(destination: TrainingEditorView(training: training)) {
                                Text(NSLocalizedString("create_training", comment: ""))
                                        .frame(width: GlobalInst.GetBtnSize(), height: GlobalInst.GetBtnSize())
                                        .foregroundColor(Color.init(UIColor.systemBackground))
                                        .background(GlobalInst.green)
                                        .clipShape(Circle())
                                        .font(.title2.bold())
                            }
                        }
                    }
                            .background(Color.clear.opacity(1))
                    Spacer().frame(height: 72)
                }
                        .navigationBarTitle(training.status == RecordStatus.statusInit.rawValue ? NSLocalizedString("inspire", comment: "") : "Today")
            }
                    .tabItem {
                        Label("Today", systemImage: "play")
                    }
                    .tag(1)


            // 计划
            NavigationView {
                StrategyView()
            }
                    .tabItem {
                        Label("Plan", systemImage: "tablecells.badge.ellipsis")
                    }
                    .tag(2)

        }
    }

    private func getStartOrContinue() -> String {
        var isStart = true
        if training.recordList != nil &&
                   training.recordList!.first != nil &&
                   training.recordList!.first!.status != RecordStatus.statusInit.rawValue {
            isStart = false
        }
        return isStart ? NSLocalizedString("start_training", comment: "") : NSLocalizedString("continue_training", comment: "")
    }
}
