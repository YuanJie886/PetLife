//
//  Item.swift
//  PetLife
//
//  Created by lhz on 2026/3/5.
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
