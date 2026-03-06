import SwiftUI
import Combine
import Foundation

// ObservableObject 表示这是一个可以被页面监听的"广播站"
class AppViewModel: ObservableObject {
    
    // @Published 表示当这个数据发生变化时，立刻广播通知所有用到它的页面刷新
    @Published var myPet: PetProfile = PetProfile(
        name: "布丁",
        breed: "布偶",
        status: "活泼",
        steps: 5240,
        calories: 320,
        sleepHours: 9
    )
    
    @Published var hotFeeds: [FeedPost] = [
        FeedPost(
            content: "今天的阳光真好，带布丁去公园撒欢啦! ☀️🐱",
            likes: 128,
            comments: 12,
            timeAgo: "10分钟前",
            imageUrl: "https://images.unsplash.com/photo-1574144113084-b6f8a66d7624?w=400&h=300"
        )
    ]
    
    // 模拟从网络加载真实数据
    func loadData() {
        // 假装网络请求花了 1 秒钟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hotFeeds = [
                FeedPost(content: "今天的阳光真好，带布丁去公园撒欢啦！☀️🐶", likes: 128, comments: 12, timeAgo: "10分钟前", imageUrl: "https://img95.699pic.com/photo/60017/9628.jpg_wh300.jpg!/fh/300/quality/90"),
                FeedPost(content: "新买的猫粮到了，主子闻到味道就跑过来了！", likes: 45, comments: 3, timeAgo: "2小时前", imageUrl: "https://img95.699pic.com/photo/60080/8313.jpg_wh860.jpg"),
                FeedPost(content: "记录一下布丁睡觉的傻样～", likes: 210, comments: 18, timeAgo: "5小时前", imageUrl: "camera.macro")
            ]
            
            // 假设宠物今天走得更多了，数据更新
            self.myPet.steps = 5800
        }
    }
}
