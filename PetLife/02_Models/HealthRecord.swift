//
//  HealthRecord.swift
//  PetLife
//
//  Created by lhz on 2026/3/9.
//

import Foundation

import FirebaseFirestore


struct HealthRecord: Codable,Identifiable {
    
    @DocumentID var id: String?
    
    var date: Date  // 记录日期
    var weight: Double // 体重
    var waterIntake: Int  // 饮水
}
