//
//  KalkulackaApp.swift
//  Kalkulacka
//
//  Created by Jan Hes on 21.06.2025.
//  TODO warnings, jazyk-jméno a lockscreen zkratky, ikona, zaoblení,odečet kroužků

import SwiftUI
import SwiftData

import UIKit

class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()
    
    @Published var pendingShortcut: String?
    @Published var shouldNavigateToTab: Int = 0
    @Published var shouldShowDrinkEntry: Bool = false
    @Published var drinkEntryType: DrinkType = .alcohol
    
    func handleShortcut(_ shortcutType: String) {
        DispatchQueue.main.async {
            self.pendingShortcut = shortcutType
            
            switch shortcutType {
            case "log-alcohol":
                self.shouldNavigateToTab = 0
                self.drinkEntryType = .alcohol
                self.shouldShowDrinkEntry = true
            case "log-caffeine":
                self.shouldNavigateToTab = 1
                self.drinkEntryType = .caffeine
                self.shouldShowDrinkEntry = true
            default:
                break
            }
        }
    }
    
    func clearShortcut() {
        pendingShortcut = nil
        shouldShowDrinkEntry = false
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        ShortcutManager.shared.handleShortcut(shortcutItem.type)
        completionHandler(true)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            ShortcutManager.shared.handleShortcut(shortcutItem.type)
        }
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
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
                .environmentObject(ShortcutManager.shared)
        }
        .modelContainer(sharedModelContainer)
    }
}
