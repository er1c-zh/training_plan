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
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>
    @State private var selection = 1
    @State private var planList = [
        Plan(Name: "day_type_1", GroupList: [
            PlanGroupItem(Group: ExerciseType(id: "深蹲"), ItemList: [
                PlanItem(Weight: 20, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                PlanItem(Weight: 60, CountPerRound: 5, CntOfRound: 4, IntervalInSeconds: 120),
            ]),
            PlanGroupItem(Group: ExerciseType(id: "卧推"), ItemList: [
                PlanItem(Weight: 20, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                PlanItem(Weight: 55, CountPerRound: 5, CntOfRound: 4, IntervalInSeconds: 120),
            ]),
            PlanGroupItem(Group: ExerciseType(id: "硬拉"), ItemList: [
                PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                PlanItem(Weight: 50, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                PlanItem(Weight: 60, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 120),
            ]),
        ]),
        Plan(Name: "day_type_2", GroupList: [
            PlanGroupItem(Group: ExerciseType(id: "深蹲"), ItemList: []),
            PlanGroupItem(Group: ExerciseType(id: "推举"), ItemList: []),
            PlanGroupItem(Group: ExerciseType(id: "硬拉"), ItemList: []),
        ]),
    ]
    @State private var groupList = [
        ExerciseType(id: "深蹲"),
        ExerciseType(id: "卧推"),
        ExerciseType(id: "硬拉"),
    ]

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
                            PlanPreview(plan: $planList[0], withDetail: true)
                            Spacer()
                            NavigationLink(destination: Text("implement me")) {
                                Text("开始")
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


                // 计划
                NavigationView{
                    PlanListView(planList: $planList)
                }
                        .tabItem {
                            Label("Plan", systemImage: "tablecells.badge.ellipsis")
                        }
                        .tag(2)

            }
    }
}
