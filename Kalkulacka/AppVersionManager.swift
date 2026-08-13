//
//  AppVersionManager.swift
//  Kalkulacka
//
//  Created by Jan Hes on 13.08.2025.
//

import Foundation

class AppVersionManager {
    static let shared = AppVersionManager()
    
    private let versionKey = "lastShownWhatsNewVersion"
    
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    func shouldShowWhatsNew() -> Bool {
        let lastShown = UserDefaults.standard.string(forKey: versionKey) ?? ""
        return lastShown != currentVersion
    }
    
    func markWhatsNewAsShown() {
        UserDefaults.standard.set(currentVersion, forKey: versionKey)
    }
}
