import SwiftUI
import FirebaseFirestore
import PhotosUI

struct PublishPostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel // 关联全局ViewModel
    
    // 动态内容
    @State private var postText = ""
    // 图片选择（真实图片上传）
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var isUploading: Bool = false
    
    // 输入状态（控制发布按钮是否可用）
    @State private var isPostValid: Bool = false
    
    // 监听输入内容，实时判断是否可发布
    private let textObserver = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification)
    
    var body: some View {
        NavigationStack { // 替换NavigationView（iOS16+推荐）
            ZStack {
                // 背景色（和主页统一）
                Color(red: 0.99, green: 0.97, blue: 0.95)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // 1. 用户头像 + 输入框区域
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 12) {
                            // 用户头像
                            ZStack {
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.91, blue: 0.74))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                            }
                            
                            // 输入框
                            VStack(alignment: .leading, spacing: 4) {
                                Text("分享你的宠物日常～")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .opacity(postText.isEmpty ? 1 : 0) // 输入内容后隐藏提示
                                
                                TextEditor(text: $postText)
                                    .frame(height: 120)
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                    .scrollContentBackground(.hidden) // 隐藏默认背景
                                    .background(Color.clear)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 输入框下划线
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal)
                    }
                    
                    // 2. 图片选择区域
                    VStack(alignment: .leading, spacing: 10) {
                        Text("添加图片")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            // 图片选择按钮
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .frame(width: 80, height: 80)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.title)
                                        .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                                }
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedUIImage = uiImage
                                    }
                                }
                            }
                            
                            // 图片预览（选中后显示）
                            if let image = selectedUIImage {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .frame(width: 80, height: 80)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // 关闭按钮
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Circle()
                                                .fill(Color.black.opacity(0.5))
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    Image(systemName: "xmark")
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                )
                                                .onTapGesture {
                                                    selectedUIImage = nil
                                                    selectedItem = nil
                                                }
                                                .padding(4)
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: 80, height: 80) // 确保 ZStack 整体与内部 frame 一致
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. 字数提示
                    HStack {
                        Text("\(postText.count)/200")
                            .font(.caption)
                            .foregroundColor(postText.count > 200 ? .red : .gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // 4. 底部发布按钮（吸底设计）
                    Button(action: {
                        if !isUploading {
                            publishPost()
                        }
                    }) {
                        HStack {
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                        Text("正在发布...")
                            } else {
                                Text("发布动态")
                            }
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isPostValid && !isUploading ? Color(red: 0.98, green: 0.69, blue: 0.29) : Color.gray.opacity(0.3))
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .disabled(!isPostValid || isUploading) // 不可用或正在上传时禁用按钮
                }
            }
            .navigationTitle("发布新动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 备用发布按钮（和底部按钮二选一，这里保留）
                    Button(isUploading ? "发布中..." : "发布") {
                        if !isUploading {
                            publishPost()
                        }
                    }
                    .foregroundColor(isPostValid && !isUploading ? Color(red: 0.98, green: 0.69, blue: 0.29) : .gray)
                    .fontWeight(.bold)
                    .disabled(!isPostValid || isUploading)
                }
            }
            .onReceive(textObserver) { _ in
                // 实时更新发布按钮状态
                isPostValid = !postText.trimmingCharacters(in: .whitespaces).isEmpty && postText.count <= 200
            }
            .onAppear {
                // 初始化状态
                isPostValid = !postText.trimmingCharacters(in: .whitespaces).isEmpty
            }
        }
    }
    
    // 发布动态核心方法
    private func publishPost() {
        // 1. 数据验证
        guard !postText.trimmingCharacters(in: .whitespaces).isEmpty, postText.count <= 200 else {
            return
        }
        
        isUploading = true
        
        if let image = selectedUIImage {
            // 如果选择了图片，先上传图片
            appViewModel.uploadImageToStorage(image: image) { url in
                DispatchQueue.main.async {
                    if let imageUrl = url {
                        saveFeed(imageUrl: imageUrl)
                    } else {
                        // 上传失败处理，使用默认占位图
                        print("❌ 图片上传失败，使用默认占位图")
                        saveFeed(imageUrl: "photo")
                        isUploading = false
                    }
                }
            }
        } else {
            // 如果没有选择图片，使用默认占位图标
            saveFeed(imageUrl: "photo")
        }
    }
    
    // 保存动态记录
    private func saveFeed(imageUrl: String) {
        // 2. 创建动态模型
        let newFeed = FeedPost(
            id: nil, // 空ID，由Firebase自动生成
            authorName: "布丁的主人", // 可替换为用户昵称（后续可扩展）
            authorAvatar: "person.circle.fill",
            content: postText,
            imageUrl: imageUrl,
            likes: 0,
            comments: 0,
            timeAgo: "刚刚" // 也可以用真实的时间，前端通常展示相对时间
        )
        
        // 3. 保存到云端
        appViewModel.saveFeedToCloud(feed: newFeed)
        
        isUploading = false
        // 4. 关闭页面
        dismiss()
    }
}

// 预览
#Preview {
    PublishPostView()
        .environmentObject(AppViewModel())
}
