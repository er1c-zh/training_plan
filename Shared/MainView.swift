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
    @State private var training: Training?

    init() {
        loadTraining()
    }

    func loadTraining() {
        training = Training.getDoingTraining()
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
                    HStack {
                        Spacer().frame(width: GlobalInst.config.Padding)
                        VStack {
                            HStack {
                                Text("Today").font(Font.system(.title))
                                Spacer()
                            }
                            Spacer().frame(height: GlobalInst.config.Padding)
                            if training != nil {
                                // TODO use workout view
                                NavigationLink(destination: TrainingEditorView()) {
                                    Text(NSLocalizedString("start_training", comment: ""))
                                }
                            } else {
                                NavigationLink(destination: TrainingEditorView()) {
                                    Text(NSLocalizedString("create_training", comment: ""))
                                }
                            }
                            Spacer()

                            Button("del") {
                                if let training = training {
                                    GlobalInst.GetContext().delete(training)
                                    GlobalInst.SaveContext()
                                }
                            }
                            Spacer().frame(height: GlobalInst.config.Padding)
                        }
                                .navigationBarTitleDisplayMode(.inline)
                        Spacer().frame(width: GlobalInst.config.Padding)
                    }
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
                NavigationView{
                    Text("implement me")
                }
                        .tabItem {
                            Label("Plan", systemImage: "tablecells.badge.ellipsis")
                        }
                        .tag(2)

            }
    }
}
