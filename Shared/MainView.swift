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
    private var didChange = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)  //the publisher
    @State private var refreshing = false

    @State private var selection = 1
    @ObservedObject private var training: Training = Training.getDoingTraining()

    var body: some View {
        TabView(selection: $selection) {
            // 统计
            NavigationView {
                Text("implement me")
            }
                    .tabItem {
                        Label("Statistic", systemImage: "chart.xyaxis.line")
                    }
                    .tag(0)

            // Today

            NavigationView {
                VStack {
                    Spacer()
                    if training.status != RecordStatus.statusInit.rawValue {
                        TrainingPreviewView(data: training.data)
                                .padding(32)
                    }

                    Spacer()

                    HStack {
                        if training.status != RecordStatus.statusInit.rawValue {
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
                                        .frame(width: 72, height: 72)
                                        .foregroundColor(Color.white)
                                        .background(Color.red)
                                        .clipShape(Circle())
                            }
                            Spacer()

                            Spacer()
                            NavigationLink(destination: TrainingView(training: training)) {
                                Text(NSLocalizedString("start_training", comment: ""))
                                        .frame(width: 72, height: 72)
                                        .foregroundColor(Color.white)
                                        .background(Color.green)
                                        .clipShape(Circle())
                            }
                            Spacer()
                        } else {
                            NavigationLink(destination: TrainingEditorView(training: training)) {
                                Text(NSLocalizedString("create_training", comment: ""))
                                        .frame(width: 72, height: 72)
                                        .foregroundColor(Color.white)
                                        .background(Color.green)
                                        .clipShape(Circle())
                            }
                        }
                    }
                            .background(Color.clear.opacity(1))
                    Spacer()
                }
                        .navigationBarTitle("Today")
            }
                    .tabItem {
                        Label("Today", systemImage: "play")
                    }
                    .tag(1)
                    .onReceive(didChange) { _ in
//                        loadTraining()
//                        refreshing.toggle()
                    }


            // 计划
            NavigationView {
                StrategyView()
            }
                    .tabItem {
                        Label("Plan", systemImage: "tablecells.badge.ellipsis")
                    }
                    .tag(2)

            NavigationView {
                DebugView()
            }
                    .tabItem {
                        Text("Debug")
                    }
                    .tag(3)
        }
    }
}
