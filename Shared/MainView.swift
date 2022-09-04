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
    @State private var training: Training? = Training.getDoingTraining()

    func loadTraining() {
        training = Training.getDoingTraining()
        GlobalInst.logger.info("loadTraining: \(training == nil)")
    }

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
                    if training != nil {
                        // TODO use workout view
                        TrainingPreviewView(data: training!.data)
                                .padding(32)
                    }

                    Spacer()

                    HStack {
                        if training != nil {
                            Spacer()
                            Button(action: {
                                if let training = training {
                                    withAnimation {
                                        GlobalInst.GetContext().delete(training)
                                        GlobalInst.SaveContext()
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("del_training", comment: ""))
                                        .frame(width: 72, height: 72)
                                        .foregroundColor(Color.white)
                                        .background(Color.red)
                                        .clipShape(Circle())
                            }
                            Spacer()
                            NavigationLink(destination: TrainingEditorView()) {
                                Text(NSLocalizedString("start_training", comment: ""))
                                        .frame(width: 72, height: 72)
                                        .foregroundColor(Color.white)
                                        .background(Color.green)
                                        .clipShape(Circle())
                            }
                            Spacer()
                        } else {
                            NavigationLink(destination: TrainingEditorView()) {
                                Text(NSLocalizedString("create_training", comment: ""))
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
                        GlobalInst.logger.info("refresh start, training: \(training == nil)")
                        if training != nil {
                            GlobalInst.logger.info("refresh start, training: \(training!.trainingID)")
                        }
                        loadTraining()
                        refreshing.toggle()
                        GlobalInst.logger.info("refresh done, training: \(training == nil)")
                        if training != nil {
                            GlobalInst.logger.info("refresh done, training: \(training!.trainingID)")
                        }
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
