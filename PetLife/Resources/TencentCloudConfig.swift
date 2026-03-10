//
//  TencentCloudConfig.swift
//  PetLife
//
//  腾讯云配置信息
//

import Foundation

struct TencentCloudConfig {
    // 腾讯云 SDK 配置
    static let secretId = "YOUR_SECRET_ID"
    static let secretKey = "YOUR_SECRET_KEY"
    static let region = "ap-guangzhou" // 根据你的实际情况修改
    
    // 云开发环境配置
    static let envId = "YOUR_ENV_ID" // 云开发环境ID
    
    // 数据库集合名称
    struct Collections {
        static let petProfiles = "pet_profiles"
        static let healthLogs = "health_logs"
        static let feeds = "feeds"
        static let petAlbums = "pet_albums"
        static let petPhotos = "pet_photos"
        static let reminders = "reminders"
        static let petNotes = "pet_notes"
    }
}
