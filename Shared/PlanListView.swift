//
// Created by eric on 2022/8/6.
//

import SwiftUI
import CoreData
import Combine

// PlanView plan列表的view
// struct PlanListView: View {
//     @Binding var planList: [Plan]
// 
//     var body: some View {
//         List {
//             Section("Plan") {
//                 ForEach($planList) { $plan in
//                     NavigationLink(destination: PlanView(plan: $plan)){
//                         PlanPreview(plan: $plan, withDetail: false)
//                     }
//                 }
//                         .onDelete { indies in
//                             withAnimation {
//                                 planList.remove(atOffsets: indies)
//                             }
//                         }
//                 HStack {
//                     Button("Add", action:
//                     {
//                         withAnimation{
//                             let tmp = Plan(Name: "New Plan", GroupList: [])
//                             planList.append(tmp)
//                         }
//                     }
//                     )
//                 }
//             }
//             Section("Exercises") {
//                 ForEach(ExerciseType.GetExerciseType()) { group in
//                     Text(group.id)
//                 }
//             }
//         }
//                 .navigationBarTitleDisplayMode(.inline)
//     }
// }
// 
// // PlanView 计划的View
// struct PlanView: View {
//     @Binding var plan: Plan
// 
//     @State private var data = Plan.Data()
//     @State private var isEditing: Bool = false
// 
//     @State private var newGroupInst: PlanGroupItem = PlanGroupItem(Group: ExerciseType.Nil(), ItemList: [])
// 
//     var body: some View {
//             List {
//                 Section(header: Text("基本信息")) {
//                     HStack {
//                         Text("标题")
//                         Spacer()
//                         Text(plan.Name)
//                     }
//                 }
// 
//                 Section(header: Text("分组"),
//                         content: {
//                             ForEach($plan.GroupList) { $group in
//                                 NavigationLink(destination: PlanGroupView(group: $group)) {
//                                     Text(group.Exercise.id)
//                                 }
//                             }
//                             HStack {
//                                 Button("Add") {
//                                     withAnimation {
//                                         let tmp = PlanGroupItem(Group: ExerciseType.WaitEdit(), ItemList: [])
//                                         plan.GroupList.append(tmp)
//                                     }
//                                 }
//                             }
//                         }
//                 )
//             }
//                     .navigationBarTitle(plan.Name)
//                     .navigationBarItems(trailing: Button("Edit") {
//                         isEditing = true
//                         data = plan.data
//                     })
//                     .sheet(isPresented: $isEditing) {
//                         NavigationView {
//                             PlanViewEditor(data: $data)
//                                     .navigationBarTitle(plan.Name)
//                                     .toolbar {
//                                         ToolbarItem(placement: .cancellationAction) {
//                                             Button("Cancel") {
//                                                 isEditing = false
//                                             }
//                                         }
//                                         ToolbarItem(placement: .confirmationAction) {
//                                             Button("Done") {
//                                                 isEditing = false
//                                                 plan.update(from: data)
//                                             }
//                                         }
//                                     }
//                         }
//                     }
//     }
// }
// 
// // PlanViewEditor 计划的Editor
// struct PlanViewEditor: View {
//     @Binding var data : Plan.Data
//     var body: some View {
//         Form {
//             Section(header: Text("基本信息")) {
//                 HStack {
//                     Text("标题")
//                     Spacer()
//                     TextField("", text: $data.Name)
//                 }
//             }
//         }
//     }
// }
// 
// // PlanGroupView 动作组的editor
// struct PlanGroupView: View {
//     @Binding var group : PlanGroupItem
// 
//     @State private var isEditing: Bool = false
//     @State private var data: PlanGroupItem.Data = PlanGroupItem.Data()
//     var body: some View {
//         List {
//             Section(header: Text("基本信息")) {
//                 HStack {
//                     Text("动作")
//                     Spacer()
//                     Text(group.Exercise.id)
//                 }
//             }
//             Section(header: Text("分组")) {
//                 ForEach($group.ItemList) { $item in
//                     PlanItemSingleRowView(item: $item)
//                 }
//             }
//         }
//                 .navigationBarTitle(group.Exercise.id)
//                 .navigationBarItems(trailing: Button("Edit") {
//                     isEditing = true
//                     data = group.data
//                 })
//                 .sheet(isPresented: $isEditing) {
//                     NavigationView {
//                         PlanGroupViewEditor(data: $data)
//                                 .navigationBarTitle(group.Exercise.id)
//                                 .toolbar {
//                                     ToolbarItem(placement: .cancellationAction) {
//                                         Button("Cancel") {
//                                             isEditing = false
//                                         }
//                                     }
//                                     ToolbarItem(placement: .confirmationAction) {
//                                         Button("Done") {
//                                             isEditing = false
//                                             group.update(from: data)
//                                         }
//                                     }
//                                 }
//                     }
//                 }
//     }
// }
// 
// struct PlanGroupViewEditor: View {
//     @Binding var data : PlanGroupItem.Data
//     @State private var isPickingExercise : Bool = false
//     @State private var isEditingItem : Bool = false
//     @State private var editingItemData : PlanItem.Data = PlanItem.Data()
//     @State private var editingItemIndies : IndexSet = IndexSet()
//     var body: some View {
//         Form {
//             List {
//                 Section(header: Text("基本信息")) {
//                     HStack {
//                         Text("动作")
//                         Spacer()
//                         Button(data.Exercise.id) {
//                             isPickingExercise = true
//                         }
//                     }
//                 }
//                 Section(header: Text("分组")) {
//                     ForEach($data.ItemList) { $item in
//                         Button(action: {
//                             editingItemData = item.data
//                             isEditingItem = true
//                         }) {
//                             PlanItemSingleRowView(item: $item)
//                         }
//                                 .sheet(isPresented: $isEditingItem) {
//                                     NavigationView {
//                                         PlanItemViewEditor(item: $editingItemData, NeedWeight: true)
//                                             .toolbar {
//                                                 ToolbarItem(placement: .cancellationAction) {
//                                                     Button("Cancel") {
//                                                         isEditingItem = false
//                                                     }
//                                                 }
//                                                 ToolbarItem(placement: .confirmationAction) {
//                                                     Button("Done") {
//                                                         isEditingItem = false
//                                                         item.update(from: editingItemData)
//                                                     }
//                                                 }
//                                             }
//                                     }
//                                 }
//                     }
//                             .onDelete { indies in
//                                 withAnimation {
//                                     data.ItemList.remove(atOffsets: indies)
//                                 }
//                             }
// 
//                     Button("Add") {
//                         withAnimation {
//                             let tmp = PlanItem(Weight: 0, CountPerRound: 0, CntOfRound: 0, IntervalInSeconds: 0)
//                             data.ItemList.append(tmp)
//                         }
//                     }
//                 }
//             }
//         }
//                 .sheet(isPresented: $isPickingExercise) {
//                     List {
//                         ForEach(ExerciseType.GetExerciseType()) { et in
//                             Button(et.id) {
//                                 isPickingExercise = false
//                                 data.Exercise = et
//                             }
//                         }
//                     }
//                 }
// 
//     }
// }
// 
// // PlanItemViewEditor 一组训练的view
// struct PlanItemViewEditor: View {
//     @Binding var item : PlanItem.Data
//     var NeedWeight: Bool
// 
//     @State private var WeightStr = ""
//     @State private var CountPerRoundStr = ""
//     @State private var CntOfRoundStr = ""
//     @State private var IntervalInSecondsStr = ""
//     var body: some View {
//         Form {
//             Section(header: Text("量")) {
//                 if NeedWeight {
//                     NumberField(v: $item.Weight, Prefix: "重量", Suffix: GlobalInst.config.WeightUnit)
//                 }
//                 NumberField(v: $item.CountPerRound, Prefix: "每组", Suffix: "次")
//                 NumberField(v: $item.CntOfRound, Prefix: "共", Suffix: "组")
//             }
//             Section(header: Text("组间休息")) {
//                 NumberField(v: $item.IntervalInSeconds, Prefix: "休息", Suffix: "s")
//             }
//         }
//     }
// }
// 
// 
// 
// struct NumberField<V>: View {
//     @Binding var v: V
//     var Prefix = ""
//     var Suffix = ""
//     var Hint = ""
// 
//     var body: some View {
//         HStack {
//             if Prefix != "" {
//                 Text(Prefix)
//             }
//             TextField(Hint, value: $v, formatter: NumberFormatter())
//                     .keyboardType(.decimalPad)
//                     .multilineTextAlignment(.trailing)
//             if Suffix != "" {
//                 Text(Suffix).frame(width: GlobalInst.config.WidthInputSuffix)
//             }
//         }
//     }
// }
// 
// 
// // PlanPreview 计划的preview
// // 有详细和缩略两种格式
// struct PlanPreview: View {
//     @Binding var plan: Plan
//     let withDetail: Bool
//     var body: some View {
//         if withDetail {
//             VStack{
//                 ForEach($plan.GroupList) { $group in
//                     VStack{
//                         PlanGroupPreview(group: $group)
//                         Spacer().frame(height: 32)
//                     }
//                 }
//             }
//         } else {
//             Text(plan.Name)
//         }
//     }
// }
// 
// struct PlanGroupPreview: View {
//     @Binding var group: PlanGroupItem
//     var body: some View{
//         VStack {
//             HStack{
//                 Text(group.Exercise.id).bold()
//                 Spacer()
//             }
//             Spacer().frame(height: 4)
//             ForEach($group.ItemList) { $item in
//                 PlanItemSingleRowView(item: $item)
//             }
//         }
//     }
// }
// 
// struct PlanItemSingleRowView: View {
//     @Binding var item : PlanItem
//     var body: some View {
//         HStack {
//             // TODO 计算每一项最长的，填充到等宽
//             Text(String(format: "%.1fkg * %d * %d", item.Weight, item.CountPerRound, item.CntOfRound))
//                     .font(getFont())
//             Spacer()
//             Text(String(format: "%ds", item.IntervalInSeconds)).font(getFont())
//         }
//     }
//     private func getFont() -> Font {
//         Font.system(size: 16).monospaced()
//     }
// }
