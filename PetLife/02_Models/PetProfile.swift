//
//  PetProfile.swift
//  PetLife
//
//  Created by lhz on 2026/3/6.
//

import Foundation

struct PetProfile: Codable {
    var name: String
    var breed: String
    var status: String
    var steps: Int
    var calories: Int
    var sleepHours: Int
}
