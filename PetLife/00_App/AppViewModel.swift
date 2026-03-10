import Foundation
import FirebaseStorage
import Combine
import FirebaseCore
import FirebaseFirestore
import SwiftUI

class AppViewModel: ObservableObject {
    @Published var myReminders: [PetReminder] = []
    
    // 👇 把主页需要的宠物档案加上
    @Published var myPet: PetProfile = PetProfile(name: "布丁", breed: "布偶", status: "活泼", steps: 5240, calories: 320, sleepHours: 9)
    
    // 👇 把主页需要的热门动态加上 (先放一条假数据垫底)
    @Published var hotFeeds: [FeedPost] = [
        FeedPost(id: "1", authorName: "布丁的主人", authorAvatar: "person.circle.fill", content: "今天的阳光真好，带布丁去公园撒欢啦! ☀️🐶", imageUrl: "photo", likes: 128, comments: 12, timeAgo: "10分钟前")
    ]
    
    private var db = Firestore.firestore()
    
    // 👇 主页需要的加载数据方法
    func loadData() {
        print("🌍 正在加载主页数据...")
        // 这里以后可以把 myPet 和 hotFeeds 也改成从 Firebase 获取
//        fetchFeedsFromCloud()
        // 目前先留空，因为上面已经有默认假数据了
    }
    
    
    // 保存动态到云端
    func saveFeedToCloud(feed: FeedPost) {
            do {
                // 如果是新动态，自动生成ID；如果是编辑，使用现有ID
                let feedRef: DocumentReference
                if feed.id?.isEmpty ?? true {
                    feedRef = db.collection("feeds").document()
                    var newFeed = feed
                    newFeed.id = feedRef.documentID
                    try feedRef.setData(from: newFeed)
                } else {
                    feedRef = db.collection("feeds").document(feed.id!)
                    try feedRef.setData(from: feed)
                }
                print("🎉 动态已成功保存到 Firebase 云端！")
                fetchFeedsFromCloud() // 保存后刷新列表
            } catch {
                print("❌ 动态保存失败: \(error.localizedDescription)")
            }
        }
    
    // 从云端拉取动态信息
    func fetchFeedsFromCloud() {
        db.collection("feeds")
            .order(by: "timeAgo",descending: true) // 按时间倒序 最新的在最前
            .getDocuments{ snapshot,error in
                if let error = error {
                    print("❌ 获取动态失败: \(error.localizedDescription)")
                    return
                }
                if let snapshot = snapshot {
                    self.hotFeeds = snapshot.documents.compactMap { document in
                        try? document.data(as: FeedPost.self)
                    }
                    print("✅ 成功从云端拉取了 \(self.hotFeeds.count) 条动态！")
                }
            }
    }
    
    // 图片上传到 Firebase Storage
    func uploadImageToStorage(image:UIImage,completion: @escaping(String?) -> Void){
        // 生成唯一图片名(避免重复)
        let imageName = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("feed_images/\(imageName)")
        
        // 压缩图片
        guard let imageData = image.jpegData(compressionQuality: 0.8)else{
            completion(nil)
            return
        }
        
        // 上传图片
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ 图片上传失败: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // 获取图片的网络URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ 获取图片URL失败: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString) // 返回图片URL
            }
        }
        
        // 监听上传进度
        uploadTask.observe(.progress) { snapshot in
            let progress = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
            print("📤 图片上传进度: \(progress * 100)%")
        }
    }
    
    // 发布动态(包含图片URL)
    func publish(content: String,imageUrl: String){
        let newFeed = FeedPost(
            id: "",
            authorName: "布丁的主人",
            authorAvatar: "person.circle.fill",
            content: content,
            imageUrl: imageUrl,
            likes: 0,
            comments: 0,
            timeAgo: "刚刚"
        )
        saveFeedToCloud(feed: newFeed)
    }
    
    // ---  Firebase 提醒事项代码 ---
    func saveReminderToCloud(reminder: PetReminder) {
        do {
            let _ = try db.collection("reminders").addDocument(from: reminder)
            print("🎉 太棒了！提醒事项已成功保存到 Firebase 云端！")
            fetchRemindersFromCloud()
        } catch {
            print("❌ 保存失败: \(error.localizedDescription)")
        }
    }
    
    func fetchRemindersFromCloud() {
        db.collection("reminders").getDocuments { snapshot, error in
            if let error = error {
                print("❌ 获取数据失败: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                self.myReminders = snapshot.documents.compactMap { document in
                    try? document.data(as: PetReminder.self)
                }
                print("✅ 成功从云端拉取了 \(self.myReminders.count) 条提醒！")
            }
        }
    }
}
