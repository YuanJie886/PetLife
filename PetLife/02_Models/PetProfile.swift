//
//  PetProfile.swift
//  PetLife
//
//  Created by lhz on 2026/3/6.
//

import Foundation

import Foundation

struct PetProfile: Codable {
    var name: String
    var breed: String
    var status: String
    var weight: Double        // 体重
    var waterIntake: Int      // 饮水量
    var nextReminder: String  // 下个提醒文字
}
