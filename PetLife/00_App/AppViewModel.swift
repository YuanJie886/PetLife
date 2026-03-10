import Foundation
import FirebaseStorage
import Combine
import FirebaseCore
import FirebaseFirestore
import SwiftUI


class AppViewModel: ObservableObject {
    @Published var myReminders: [PetReminder] = []
    @Published var healthHistory: [HealthRecord] = []
    // 把主页需要的宠物档案加上
    @Published var myPet: PetProfile = PetProfile(
            name: "布丁",
            breed: "布偶",
            status: "活泼",
            weight: 4.5,            // 初始体重
            waterIntake: 150,       // 初始饮水
            nextReminder: "计算中..." // 占位字符
        )
    
    // 把主页需要的热门动态加上
    @Published var hotFeeds: [FeedPost] = []
    
    private var db = Firestore.firestore()
    
    // 主页需要的加载数据方法
    func loadData() {
        print("🌍 正在加载主页数据...")
        // 真正从 Firebase 获取最新动态
        fetchFeedsFromCloud()
        fetchRemindersFromCloud() // 如果有提醒事项需求，一并加载
    }
    
    // 保存历史记录到子集合
    func saveDailyLog(weight:Double,water:Int){
        let newRecord = HealthRecord(date:Date(),weight: weight,waterIntake: water)
        
        do{
            let _ = try db.collection("pet_profiles")
                .document("my_pet_id")
                .collection("health_logs")
                .addDocument(from:newRecord)
            
            print("✅历史记录已存入云盘")
        }catch{
            print("❌ 历史记录保存失败: \(error)")
        }
    }
    
    // 获取最近7天的历史记录用于绘图
    
    func fetchHealthHistory() {
        db.collection("pet_profiles")
            .document("my_pet_id")
            .collection("health_logs")
            .order(by:"date",descending:false) // 按时间正序排列
            .limit(toLast: 7) // 只取最近 7 条
            .addSnapshotListener { snapshot, error in
              guard let documents = snapshot?.documents else { return }
              self.healthHistory = documents.compactMap { try? $0.data(as: HealthRecord.self) }
          }
    }
    
    
    // 计算最近的一个提醒事项并更新到看板
    func updateNextReminderInfo() {
        // 1. 筛选出未来的提醒（使用 nextReminderDate），并按时间先后排序
        // 注意：这里去掉了 isCompleted 判断，因为你的模型中目前没有这个字段
        let futureReminders = myReminders
            .filter { $0.nextReminderDate > Date() }
            .sorted { $0.nextReminderDate < $1.nextReminderDate }
        
        if let next = futureReminders.first {
            // 2. 计算天数差
            let days = Calendar.current.dateComponents([.day], from: Date(), to: next.nextReminderDate).day ?? 0
            
            // 3. 格式化文案
            let dayText: String
            if days == 0 {
                dayText = "今天"
            } else if days < 0 {
                dayText = "已过期"
            } else {
                dayText = "\(days)天后"
            }
            
            // 4. 回到主线程更新 UI
            DispatchQueue.main.async {
                self.myPet.nextReminder = "\(dayText) \(next.title)"
            }
        } else {
            DispatchQueue.main.async {
                self.myPet.nextReminder = "暂无日程"
            }
        }
    }
    
    // 在 AppViewModel.swift 中添加
    func savePetProfileToCloud() {
        // 假设我们只管理一只宠物，固定 ID 为 "my_pet_id"
        let petRef = db.collection("pet_profiles").document("my_pet_id")
        
        do {
            try petRef.setData(from: self.myPet) // 直接将结构体转为 Firestore 文档
            print("🎉 宠物健康数据已同步至云端！")
        } catch {
            print("❌ 同步失败: \(error.localizedDescription)")
        }
    }

    // 同时修改 loadData，确保启动时从云端读取最新数值
    func fetchPetProfileFromCloud() {
        db.collection("pet_profiles").document("my_pet_id").addSnapshotListener { snapshot, error in
            guard let document = snapshot else { return }
            try? self.myPet = document.data(as: PetProfile.self)
        }
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
                .order(by: "timeAgo", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ 获取动态失败: \(error.localizedDescription)")
                        return
                    }
                    DispatchQueue.main.async {
                        if let snapshot = snapshot {
                            self.hotFeeds = snapshot.documents.compactMap { try? $0.data(as: FeedPost.self) }
                            print("✅ 拉取了 \(self.hotFeeds.count) 条动态")
                        }
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
                DispatchQueue.main.async {
                    if let snapshot = snapshot {
                        self.myReminders = snapshot.documents.compactMap { try? $0.data(as: PetReminder.self) }
                        print("✅ 拉取了 \(self.myReminders.count) 条提醒")
                        // 获取完提醒后，立即更新首页看板的提醒文字
                        self.updateNextReminderInfo()
                    }
                }
            }
        }
}
