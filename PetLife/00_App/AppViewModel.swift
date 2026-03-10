import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import SwiftUI
import CommonCrypto


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
    
    // 相册功能的数据
    @Published var petAlbums: [PetAlbum] = []
    @Published var petPhotos: [PetPhoto] = []
    
    // 按相册ID缓存照片（可选优化，目前可以通过petPhotos过滤）
    // @Published var photosByAlbum: [String: [PetPhoto]] = [:]
    
    private var db = Firestore.firestore()
    
    // 主页需要的加载数据方法
    func loadData() {
        print("🌍 正在加载主页数据...")
        // 真正从 Firebase 获取最新动态
        fetchFeedsFromCloud()
        fetchRemindersFromCloud() // 如果有提醒事项需求，一并加载
        fetchAlbumsFromCloud() // 加载相册列表
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
                if let id = feed.id, !id.isEmpty {
                    try db.collection("feeds").document(id).setData(from: feed)
                } else {
                    let _ = try db.collection("feeds").addDocument(from: feed)
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
    
    // 保存新相册到云端
    func saveAlbumToCloud(title: String) {
        let newAlbum = PetAlbum(id: nil, title: title, coverImageUrl: nil, createdAt: Date())
        do {
            let _ = try db.collection("pet_albums").addDocument(from: newAlbum)
            print("🎉 相册创建成功！")
            fetchAlbumsFromCloud() // 保存后刷新列表
        } catch {
            print("❌ 相册创建失败: \(error.localizedDescription)")
        }
    }
    
    // 从云端拉取相册列表
    func fetchAlbumsFromCloud() {
        db.collection("pet_albums")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 获取相册失败: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    if let snapshot = snapshot {
                        self.petAlbums = snapshot.documents.compactMap { try? $0.data(as: PetAlbum.self) }
                        print("✅ 拉取了 \(self.petAlbums.count) 个相册")
                    }
                }
            }
    }

    // 保存相册照片到云端
    func savePhotoToCloud(photo: PetPhoto) {
        do {
            let _ = try db.collection("pet_photos").addDocument(from: photo)
            print("🎉 照片已成功保存到 Firebase 云端！")
            fetchPhotosFromCloud(albumId: photo.albumId) // 保存后按相册刷新照片
            
            // 更新相册封面 (如果相册封面为空)
            if let albumIndex = self.petAlbums.firstIndex(where: { $0.id == photo.albumId }),
               self.petAlbums[albumIndex].coverImageUrl == nil {
                updateAlbumCover(albumId: photo.albumId, coverUrl: photo.imageUrl)
            }
        } catch {
            print("❌ 照片保存失败: \(error.localizedDescription)")
        }
    }
    
    private func updateAlbumCover(albumId: String, coverUrl: String) {
        db.collection("pet_albums").document(albumId).updateData(["coverImageUrl": coverUrl]) { error in
            if let error = error {
                print("❌ 更新相册封面失败: \(error.localizedDescription)")
            } else {
                self.fetchAlbumsFromCloud() // 重新拉取所有相册更新UI
            }
        }
    }
    
    // 从云端拉取指定相册照片
    func fetchPhotosFromCloud(albumId: String) {
        db.collection("pet_photos")
            .whereField("albumId", isEqualTo: albumId)
            // Firebase 需要复合索引如果使用了 whereField 和 order(by:)
            // 如果没建索引可能报错，先简单过滤后本地排序，或直接查再排序
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 获取照片失败: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    if let snapshot = snapshot {
                        var photos = snapshot.documents.compactMap { try? $0.data(as: PetPhoto.self) }
                        photos.sort { $0.createdAt > $1.createdAt } // 本地排序，避免Firebase索引报错
                        self.petPhotos = photos
                        print("✅ 查到并拉取了 \(self.petPhotos.count) 张照片(相册: \(albumId))")
                    }
                }
            }
    }
    
    // 删除照片
    func deletePhoto(photo: PetPhoto) {
        guard let id = photo.id else { return }
        db.collection("pet_photos").document(id).delete { error in
            if let error = error {
                print("❌ 删除照片失败: \(error.localizedDescription)")
            } else {
                print("✅ 照片删除成功")
                self.fetchPhotosFromCloud(albumId: photo.albumId)
                
                // 为了健壮性，若删除的是封面图可以更新封面，此处暂略
            }
        }
    }
    
    // 修改照片信息
    func updatePhoto(photo: PetPhoto) {
        guard let id = photo.id else { return }
        do {
            try db.collection("pet_photos").document(id).setData(from: photo)
            print("✅ 照片信息修改成功")
            self.fetchPhotosFromCloud(albumId: photo.albumId)
        } catch {
            print("❌ 修改照片信息失败: \(error.localizedDescription)")
        }
    }
    
    // 图片上传到 MinIO
    func uploadImageToStorage(image: UIImage, completion: @escaping (String?) -> Void) {
        // 生成唯一图片名(避免重复)
        let imageName = UUID().uuidString + ".jpg"

        // 压缩图片
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
            completion(nil)
            return
        }

        // MinIO 配置
        let minioHost = "http://localhost:9000"
        let bucket = "pet-posts"
        let accessKey = "admin"
        let secretKey = "admin123456"

        let urlString = "\(minioHost)/\(bucket)/\(imageName)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        // 使用 AWS Signature V4 签名
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let amzDate = dateFormatter.string(from: Date())

        let dateStamp = String(amzDate.prefix(8))
        let region = "us-east-1"
        let service = "s3"

        // 计算哈希
        func sha256(_ data: Data) -> Data {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes { buffer in
                _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
            }
            return Data(hash)
        }

        func hmacSHA256(key: Data, data: Data) -> Data {
            var macData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            macData.withUnsafeMutableBytes { macBytes in
                key.withUnsafeBytes { keyBytes in
                    data.withUnsafeBytes { dataBytes in
                        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
                               keyBytes.baseAddress, keyBytes.count,
                               dataBytes.baseAddress, dataBytes.count,
                               macBytes.bindMemory(to: UInt8.self).baseAddress)
                    }
                }
            }
            return macData
        }

        let payloadHash = sha256(imageData).map { String(format: "%02x", $0) }.joined()

        // 创建规范请求
        let canonicalRequest = """
            PUT
            /\(bucket)/\(imageName)

            content-type:image/jpeg
            host:localhost:9000
            x-amz-content-sha256:\(payloadHash)
            x-amz-date:\(amzDate)

            content-type;host;x-amz-content-sha256;x-amz-date
            \(payloadHash)
            """

        // 创建待签名字符串
        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"
        let stringToSign = """
            AWS4-HMAC-SHA256
            \(amzDate)
            \(credentialScope)
            \(sha256(Data(canonicalRequest.utf8)).map { String(format: "%02x", $0) }.joined())
            """

        // 计算签名
        let dateKey = hmacSHA256(key: Data("AWS4\(secretKey)".utf8), data: Data(dateStamp.utf8))
        let dateRegionKey = hmacSHA256(key: dateKey, data: Data(region.utf8))
        let dateRegionServiceKey = hmacSHA256(key: dateRegionKey, data: Data(service.utf8))
        let signingKey = hmacSHA256(key: dateRegionServiceKey, data: Data("aws4_request".utf8))
        let signature = hmacSHA256(key: signingKey, data: Data(stringToSign.utf8))
            .map { String(format: "%02x", $0) }.joined()

        // 设置授权头
        let authHeader = "AWS4-HMAC-SHA256 Credential=\(accessKey)/\(credentialScope), SignedHeaders=content-type;host;x-amz-content-sha256;x-amz-date, Signature=\(signature)"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue(amzDate, forHTTPHeaderField: "x-amz-date")
        request.setValue(payloadHash, forHTTPHeaderField: "x-amz-content-sha256")

        // 执行上传
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error {
                print("❌ 图片上传失败: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let imageUrl = "\(minioHost)/\(bucket)/\(imageName)"
                print("✅ 图片上传成功: \(imageUrl)")
                completion(imageUrl)
            } else {
                print("❌ 图片上传失败，状态码: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                completion(nil)
            }
        }

        task.resume()
    }
    
    // 发布动态(包含图片URL)
    func publish(content: String,imageUrl: String){
        let newFeed = FeedPost(
            id: nil,
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
    
    func deleteReminder(reminder: PetReminder) {
        db.collection("reminders").whereField("id", isEqualTo: reminder.id).getDocuments { snapshot, error in
            if let error = error {
                print("❌ 删除失败: \(error.localizedDescription)")
                return
            }
            for document in snapshot?.documents ?? [] {
                document.reference.delete()
            }
            print("✅ 提醒事项已删除")
            self.fetchRemindersFromCloud()
        }
    }
    
    func updateReminderInCloud(reminder: PetReminder) {
        db.collection("reminders").whereField("id", isEqualTo: reminder.id).getDocuments { snapshot, error in
            if let error = error {
                print("❌ 更新失败: \(error.localizedDescription)")
                return
            }
            for document in snapshot?.documents ?? [] {
                do {
                    try document.reference.setData(from: reminder)
                    print("✅ 提醒事项已更新")
                } catch {
                    print("❌ 更新数据出错: \(error.localizedDescription)")
                }
            }
            self.fetchRemindersFromCloud()
        }
    }
}
