//
//  SceneDelegate.swift
//  Kalkulacka
//
//  Created by Jan Hes on 19.07.2025.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Handle shortcut if app was launched via quick action
        if let shortcutItem = connectionOptions.shortcutItem {
            ShortcutManager.shared.handleShortcut(shortcutItem.type)
        }
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        ShortcutManager.shared.handleShortcut(shortcutItem.type)
        completionHandler(true)
    }
}

