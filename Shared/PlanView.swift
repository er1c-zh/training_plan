//
// Created by eric on 2022/8/6.
//

import SwiftUI
import CoreData

struct PlanView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
            }
                    .toolbar {
                        // ToolbarItem {
                        //     Button(action: addItem) {
                        //         Label("Add Item", systemImage: "plus")
                        //     }
                        // }
                    }
            Text("Select an item")
        }
    }
}

struct PlanPreview: View {
    let plan: Plan
    var body: some View {
        VStack{
            Text(plan.Name)
            List{
                ForEach(plan.GroupList) { group in VStack{
                        Text(group.Name)
                        ForEach(group.ItemList) { item in VStack{
                                Text(String(format:"%dkg * %d * %d rest: %ds", item.Weight, item.CountPerRound,
                                        item.CntOfRound, item.IntervalInSeconds))
                            }
                        }
                    }
                }
            }
        }
    }
}