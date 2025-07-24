//
//  KalkulackaApp.swift
//  Kalkulacka
//
//  Created by Jan Hes on 21.06.2025.
//

import SwiftUI
import SwiftData

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    @objc dynamic var shortcutType: String?

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("AppDelegate: performActionFor shortcut \(shortcutItem.type)")
        shortcutType = shortcutItem.type
        UserDefaults.standard.set(shortcutItem.type, forKey: "launchShortcutType")
        completionHandler(true)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            print("AppDelegate: didFinishLaunchingWithOptions shortcut \(shortcutItem.type)")
            shortcutType = shortcutItem.type
            UserDefaults.standard.set(shortcutItem.type, forKey: "launchShortcutType")
        }
        return true
    }
}

@main
struct KalkulackaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
