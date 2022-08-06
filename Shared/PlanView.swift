//
// Created by eric on 2022/8/6.
//

import SwiftUI
import CoreData

// PlanView plan列表的view
struct PlanView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>

    var planList: [Plan]

    var body: some View {
        List {
            ForEach(planList) { plan in
                NavigationLink(destination: PlanDetailView(isNew: false, plan: plan)){
                    PlanPreview(plan: plan, withDetail: false)
                }
            }
        }
                .navigationBarTitle("计划")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: NavigationLink(destination: PlanDetailView(isNew: true, plan: PlanFactory().New())){
                    Label("", systemImage: "plus")
                })
    }
}

// PlanDetailView 一个计划的详情
struct PlanDetailView: View {
    var isNew: Bool
    var plan: Plan
    var body: some View {
//        HStack{
//            Spacer().frame(width: GlobalInst.config.Padding)
//            VStack{
//                Spacer().frame(height: GlobalInst.config.Padding)
                PlanDetail(plan: plan)
        Spacer()
//            }.background(.green)
//            Spacer().frame(width: GlobalInst.config.Padding)
//        }.navigationBarTitle(isNew ? "新增" : "修改")
    }
}

struct PlanDetail: View {
    @State var plan: Plan
    var body: some View {
            List {
                Section(header: Text("基本信息")) {
                    HStack {
                        Text("标题")
                        Spacer()
                        TextField("", text: $plan.Name)
                    }
                }

                Section(header: Text("分组"),
                        content: {
                            ForEach($plan.GroupList) { $group in
                                NavigationLink(destination: PlanGroupDetail(group: group)) {
                                    Text(group.Name)
                                }
                            }
                    NavigationLink(destination: PlanGroupDetail(group: PlanGroupItem(Name: "", ItemList: []))) {
                        Text("新增").foregroundColor(.blue)
                    }
                        }
                )
            }.navigationBarTitle(plan.Name)
    }
}

struct PlanGroupDetail: View {
    @State var group: PlanGroupItem
    var body: some View {
        List {
            Section(header: Text("分组")) {
                ForEach($group.ItemList) { $item in
                    Text(String(format: "%dkg * %d * %d / %ds", item.Weight, item.CountPerRound, item.CntOfRound, item.IntervalInSeconds))
                }
                NavigationLink(destination: PlanGroupDetail(group: PlanGroupItem(Name: "", ItemList: []))) {
                    Text("新增").foregroundColor(.blue)
                }
            }
        }.navigationBarTitle(group.Name)
    }
}

// PlanPreview 计划的preview
// 有详细和缩略两种格式
struct PlanPreview: View {
    let plan: Plan
    let withDetail: Bool
    var body: some View {
        if withDetail {
            VStack{
                ForEach(plan.GroupList) { group in
                    VStack{
                        PlanGroupPreview(group: group)
                        Spacer().frame(height: 32)
                    }
                }
            }
        } else {
            Text(plan.Name)
        }
    }
}

struct PlanGroupPreview: View {
    let group: PlanGroupItem
    var body: some View{
        VStack() {
            HStack{
                Text(group.Name).bold()
                Spacer()
            }
            Spacer().frame(height: 4)
            ForEach(group.ItemList) { item in
                HStack {
                    // TODO 计算每一项最长的，填充到等宽
                    Text(String(format: "%dkg * %d * %d", item.Weight, item.CountPerRound, item.CntOfRound))
                            .font(getFont())
                    Spacer()
                    Text(String(format: "%ds", item.IntervalInSeconds)).font(getFont())
                }
            }
        }
    }
    private func getFont() -> Font {
        Font.system(size: 16).monospaced()
    }
}

struct PlanPreview_Previews: PreviewProvider {
    static var previews: some View {
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
    }
}

struct PlanItemEditor: View {
    var body: some View {
        Text("implement me")
    }
}