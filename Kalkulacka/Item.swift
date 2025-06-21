//
//  Item.swift
//  Kalkulacka
//
//  Created by Jan Hes on 21.06.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
