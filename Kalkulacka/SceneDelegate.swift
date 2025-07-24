//
//  SceneDelegate.swift
//  Kalkulacka
//
//  Created by Jan Hes on 19.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("SceneDelegate: performActionFor shortcut \(shortcutItem.type)")
        UserDefaults.standard.set(shortcutItem.type, forKey: "launchShortcutType")
        completionHandler(true)
    }
}

