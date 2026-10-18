//
//  DeviceLayoutHelper.swift
//  Kalkulacka
//
//  Created for iPhone Duo support.
//

import SwiftUI
import UIKit

struct DeviceLayoutHelper {
    static var isIPhoneDuo: Bool {
        #if targetEnvironment(simulator)
        if let simDevice = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"],
           simDevice.contains("iPhone Duo") {
            return true
        }
        #endif
        
        let deviceName = UIDevice.current.name
        if deviceName.contains("iPhone Duo") {
            return true
        }
        
        var sysinfo = utsname()
        uname(&sysinfo)
        let machine = withUnsafeBytes(of: &sysinfo.machine) { ptr in
            String(cString: ptr.baseAddress!.assumingMemoryBound(to: CChar.self))
        }
        return machine.contains("iPhone19,4")
    }
    
    /// Returns true ONLY when iPhone Duo is in folded state.
    /// When unfolded, portrait screen is 669 x 951 pt (min dimension 669 pt, max dimension 951 pt).
    /// When folded, portrait screen is 466 x 678 pt (min dimension 466 pt, max dimension 678 pt).
    static func isIPhoneDuoFolded(size: CGSize? = nil) -> Bool {
        guard isIPhoneDuo else { return false }
        
        // 1. Check active UIScreen bounds
        let screen = UIScreen.main.bounds.size
        let screenMin = min(screen.width, screen.height)
        let screenMax = max(screen.width, screen.height)
        
        // Unfolded iPhone Duo screen is 669 x 951 pt (or 951 x 669 pt in landscape)
        if screenMin >= 550 || screenMax >= 850 {
            return false
        }
        
        // 2. If a geometry size was provided, also verify that its minimum dimension is folded
        if let size = size, size.width > 50 && size.height > 50 {
            let geomMin = min(size.width, size.height)
            if geomMin >= 550 {
                return false
            }
        }
        
        // Folded iPhone Duo has screenMin ~466 pt and screenMax ~678 pt
        return screenMin < 550 && screenMax < 800
    }
}
