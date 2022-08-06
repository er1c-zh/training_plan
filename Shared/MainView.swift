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

    var body: some View {
        NavigationView {
            HStack {
                Spacer().frame(width: GlobalInst.config.Padding)
                VStack {
                    HStack {
                        Text("Today").font(Font.system(.title))
                        Spacer()
                    }
                    Spacer().frame(height: GlobalInst.config.Padding)
                    PlanPreview(plan: Plan(Name: "hello_plan_preview", GroupList: [
                        PlanGroupItem(Name: "深蹲", ItemList: [
                            PlanItem(Weight: 20, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                            PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                            PlanItem(Weight: 60, CountPerRound: 5, CntOfRound: 4, IntervalInSeconds: 120),
                        ]),
                        PlanGroupItem(Name: "卧推", ItemList: [
                            PlanItem(Weight: 20, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                            PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                            PlanItem(Weight: 55, CountPerRound: 5, CntOfRound: 4, IntervalInSeconds: 120),
                        ]),
                        PlanGroupItem(Name: "硬拉", ItemList: [
                            PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                            PlanItem(Weight: 50, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                            PlanItem(Weight: 60, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 120),
                        ]),
                    ]), withDetail: true)
                    Spacer()
                    NavigationLink(destination: Text("implement me")) {
                        Text("开始")
                    }
                }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(trailing: NavigationLink(destination: PlanView(planList: [
                            Plan(Name: "day_type_1", GroupList: [
                                PlanGroupItem(Name: "深蹲", ItemList: [
                                    PlanItem(Weight: 20, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                                    PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                                    PlanItem(Weight: 60, CountPerRound: 5, CntOfRound: 4, IntervalInSeconds: 120),
                                ]),
                                PlanGroupItem(Name: "卧推", ItemList: [
                                    PlanItem(Weight: 20, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                                    PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                                    PlanItem(Weight: 55, CountPerRound: 5, CntOfRound: 4, IntervalInSeconds: 120),
                                ]),
                                PlanGroupItem(Name: "硬拉", ItemList: [
                                    PlanItem(Weight: 40, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 60),
                                    PlanItem(Weight: 50, CountPerRound: 5, CntOfRound: 1, IntervalInSeconds: 60),
                                    PlanItem(Weight: 60, CountPerRound: 5, CntOfRound: 2, IntervalInSeconds: 120),
                                ]),
                            ]),
                            Plan(Name: "day_type_2", GroupList: [
                                PlanGroupItem(Name: "深蹲", ItemList: []),
                                PlanGroupItem(Name: "推举", ItemList: []),
                                PlanGroupItem(Name: "硬拉", ItemList: []),
                            ]),
                        ])) {
                            Label("", systemImage: "square.and.pencil")
                        })
                Spacer().frame(width: GlobalInst.config.Padding)
            }
        }
    }
}
