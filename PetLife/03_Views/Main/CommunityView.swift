import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var appViewModel: AppViewModel // 👈 引入全局 ViewModel
    
    var body: some View {
        ZStack {
            // 背景色
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 👇 1. 自定义顶部导航栏
                HStack(spacing: 25) {
                    // "社区" 选项
                    VStack(spacing: 6) {
                        Text("社区")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                        // 底部橙色下划线
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 25, height: 3)
                            .cornerRadius(1.5)
                    }
                    
                    // "话题" 选项
                    VStack(spacing: 6) {
                        Text("话题")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        // 透明占位，保持高度一致
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 25, height: 3)
                    }
                    
                    Spacer()
                    
                    // 搜索按钮
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 15)
                .background(Color.white)
                
                // 👇 2. 可滚动的帖子列表
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if appViewModel.hotFeeds.isEmpty {
                            ProgressView("正在加载动态...")
                                .padding(.top, 50)
                        } else {
                            // 👇 循环渲染真实的云端动态
                            ForEach(appViewModel.hotFeeds) { post in
                                NavigationLink(destination: FeedDetailView(post: post)) {
                                    CommunityPostCard(post: post)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.vertical, 15)
                }
            }
        }
        .onAppear {
            // 如果数据为空，再去请求一次（防止从其他入口进来时没加载）
            if appViewModel.hotFeeds.isEmpty {
                appViewModel.fetchFeedsFromCloud()
            }
        }
        // 隐藏系统自带的导航栏标题，因为我们上面自定义了更好看的
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 子组件：社区帖子卡片
struct CommunityPostCard: View {
    let post: FeedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 用户头像与昵称
            HStack {
                Image(systemName: post.authorAvatar)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29)) // 换回主题色
                
                Text(post.authorName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Spacer()
                
                Text(post.timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 帖子文本内容
            Text(post.content)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .lineLimit(3)
            
            // 图片展示逻辑 (与DynamicFeedCard类似)
            Group {
                if post.imageUrl.starts(with: "http") {
                    AsyncImage(url: URL(string: post.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 180)
                                .clipped()
                                .cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        @unknown default:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                } else if UIImage(named: post.imageUrl) != nil {
                    Image(post.imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 180)
                        .clipped()
                        .cornerRadius(10)
                } else if !post.imageUrl.isEmpty {
                    Image(systemName: post.imageUrl)
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            
            // 底部操作区 (点赞、评论、分享)
            HStack {
                Image(systemName: "heart")
                Text("\(post.likes)")
                Spacer().frame(width: 20)
                Image(systemName: "message")
                Text("\(post.comments)")
                Spacer()
                Image(systemName: "square.and.arrow.up")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    CommunityView()
        .environmentObject(AppViewModel())
}
