import Foundation

// 宠物的基本信息
struct PetProfile: Identifiable {
    let id = UUID() // 每个数据必须有一个唯一的身份证号
    var name: String
    var breed: String
    var status: String
    var steps: Int
    var calories: Int
    var sleepHours: Int
}

// 社区的动态帖子
struct FeedPost: Identifiable {
    let id = UUID()
    var content: String
    var likes: Int
    var comments: Int
    var timeAgo: String
    // 实际开发中这里会是网络图片的 URL，现在我们先用字符串模拟
    var imageUrl: String
}
