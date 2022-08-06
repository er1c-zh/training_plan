//
//  trainingApp.swift
//  Shared
//
//  Created by eric on 2022/8/5.
//
//

import SwiftUI

@main
struct trainingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
