//
//  FeedPost.swift
//  PetLife
//
//  Created by lhz on 2026/3/6.
//

import Foundation
import SwiftUI
import Combine  
import FirebaseCore
import FirebaseFirestore



struct FeedPost: Codable, Identifiable {
    @DocumentID var id: String?  // 支持Firestore自动绑定id
    var authorName: String
    var authorAvatar: String
    var content: String
    var imageUrl: String
    var likes: Int
    var comments: Int
    var timeAgo: String
}
