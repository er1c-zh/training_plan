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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        ValueTransformer.setValueTransformer(recordListTransformer(), forName: .recordListTransformer)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.criticalAlert, .alert, .sound]) { granted, error in

            if let error = error {
                // Handle the error here.
                print("request authorization of .alert && .sound fail: \(error)")
            } else {
                GlobalInst.logger.info("request authorization of .alert && .sound success.")
            }
        }
        center.delegate = appDelegate as UNUserNotificationCenterDelegate
    }


    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                        @escaping (UNNotificationPresentationOptions) -> Void) {
        GlobalInst.logger.info("get msg: \(notification.request.identifier)")
        if notification.request.identifier == "dev.er1c.dev.rest_end" {
            completionHandler(.banner)
            return
        }
        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    }

}
