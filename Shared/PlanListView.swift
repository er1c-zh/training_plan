//
// Created by eric on 2022/8/6.
//

import SwiftUI
import CoreData
import Combine

// PlanView plan列表的view
struct PlanListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>

    @Binding var planList: [Plan]

    var body: some View {
        List {
            ForEach($planList) { $plan in
                NavigationLink(destination: PlanView(plan: $plan)){
                    PlanPreview(plan: plan, withDetail: false)
                }
            }
        }
                .navigationBarTitleDisplayMode(.inline)
        // TODO Add Plan
    }
}

// PlanView 计划的View
struct PlanView: View {
    @Binding var plan: Plan

    @State private var data = Plan.Data()
    @State private var isEditing: Bool = false;
    var body: some View {
            List {
                Section(header: Text("基本信息")) {
                    HStack {
                        Text("标题")
                        Spacer()
                        Text(plan.Name)
                    }
                }

                Section(header: Text("分组"),
                        content: {
                            ForEach(plan.GroupList) { group in
                                NavigationLink(destination: PlanGroupView(group: group)) {
                                    Text(group.Group.Name)
                                }
                            }
                            NavigationLink(destination: PlanGroupView(group: PlanGroupItem(Group: PlanGroup(Name: ""), ItemList: []))) {
                                Text("新增").foregroundColor(.blue)
                            }
                        }
                )
            }
                    .navigationBarTitle(plan.Name)
                    .navigationBarItems(trailing: Button("Edit") {
                        isEditing = true
                        data = plan.data
                    })
                    .sheet(isPresented: $isEditing) {
                        NavigationView {
                            PlanViewEditor(data: $data)
                                    .navigationBarTitle(plan.Name)
                                    .toolbar {
                                        ToolbarItem(placement: .cancellationAction) {
                                            Button("Cancel") {
                                                isEditing = false
                                            }
                                        }
                                        ToolbarItem(placement: .confirmationAction) {
                                            Button("Done") {
                                                isEditing = false
                                                plan.update(from: data)
                                            }
                                        }
                                    }
                        }
                    }
    }
}

// PlanViewEditor 计划的Editor
struct PlanViewEditor: View {
    @Binding var data : Plan.Data
    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                HStack {
                    Text("标题")
                    Spacer()
                    TextField("", text: $data.Name)
                }
            }

            Section(header: Text("分组"),
                    content: {
                        ForEach($data.GroupList) { $group in
                            NavigationLink(destination: PlanGroupView(group: group)) {
                                Text(group.Group.Name)
                            }
                        }
                                .onDelete { indices in
                                    data.GroupList.remove(atOffsets: indices)
                                }
                        // TODO AddItem
                    }
            )
        }
        Text("implement me")
    }
}

// PlanGroupView 动作组的view
struct PlanGroupView: View {
    @State var group: PlanGroupItem
    var body: some View {
        List {
            Section(header: Text("基本信息")) {
                HStack {
                    Text("标题")
                    Spacer()
                    TextField("", text: $group.Group.Name)
                }
            }
            Section(header: Text("分组")) {
                ForEach($group.ItemList) { $item in
                    NavigationLink(destination: PlanItemView(NeedWeight: true)) {
                        Text(String(format: "%dkg * %d * %d / %ds", item.Weight, item.CountPerRound, item.CntOfRound, item.IntervalInSeconds))
                    }
                }
                NavigationLink(destination: PlanItemView(NeedWeight: true)) {
                    Text("新增").foregroundColor(.blue)
                }
            }
        }.navigationBarTitle(group.Group.Name)
    }
}

// PlanGroupViewEditor 动作组的editor
struct PlanGroupViewEditor: View {
    var body: some View {
        Text("implement me")
    }
}

// PlanItemView 一组训练的view
struct PlanItemView: View {
    var NeedWeight: Bool
    @State private var WeightStr = ""
    @State private var CountPerRoundStr = ""
    @State private var CntOfRoundStr = ""
    @State private var IntervalInSecondsStr = ""
    var body: some View {
        Form {
            Section(header: Text("量")) {
                if NeedWeight {
                    NumberField(Prefix: "重量", Suffix: GlobalInst.config.WeightUnit)
                }
                NumberField(Prefix: "每组", Suffix: "次")
                NumberField(Prefix: "共", Suffix: "组")
            }
            Section(header: Text("组间休息")) {
                NumberField(Prefix: "休息", Suffix: "s")
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        true
    }
}

// PlanItemViewEditor 一组训练的editor
struct PlanItemViewEditor: View {
    var body: some View {
        Text("implement me")
    }
}

struct NumberField: View {
    @State var v = ""
    var Prefix = ""
    var Suffix = ""
    var Hint = ""

    var body: some View {
        HStack {
            if Prefix != "" {
                Text(Prefix)
            }
            TextField(Hint, text: $v)
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
                    .onReceive(Just(v)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            v = filtered
                        }
                    }
            if Suffix != "" {
                Text(Suffix).frame(width: GlobalInst.config.WidthInputSuffix)
            }
        }
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
        VStack {
            HStack{
                Text(group.Group.Name).bold()
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
