import SwiftUI

struct CommunityView: View {
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
                        // 模拟第一条帖子
                        CommunityPostCard(
                            avatar: "person.circle.fill",
                            name: "铲屎官小王",
                            time: "2小时前",
                            content: "周末想组织大家带毛孩子去西山公园聚聚，有人组队吗？✨",
                            imageCount: 2,
                            likes: 42,
                            comments: 15
                        )
                        
                        // 模拟第二条帖子
                        CommunityPostCard(
                            avatar: "person.crop.circle",
                            name: "加菲猫猫馆",
                            time: "5小时前",
                            content: "今日店里的猫主子们在线接客啦，欢迎大家来撸猫~ 🍵",
                            imageCount: 1,
                            likes: 128,
                            comments: 36
                        )
                    }
                    .padding(.vertical, 15)
                }
            }
        }
        // 隐藏系统自带的导航栏标题，因为我们上面自定义了更好看的
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 子组件：社区帖子卡片
struct CommunityPostCard: View {
    let avatar: String
    let name: String
    let time: String
    let content: String
    let imageCount: Int
    let likes: Int
    let comments: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 用户头像与昵称
            HStack {
                Image(systemName: avatar)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.gray.opacity(0.5))
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Spacer()
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 帖子文本内容
            Text(content)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .lineLimit(3)
            
            // 模拟图片网格
            if imageCount > 0 {
                HStack(spacing: 10) {
                    ForEach(0..<imageCount, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 120)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                    }
                }
            }
            
            // 底部操作区 (点赞、评论、分享)
            HStack {
                Image(systemName: "heart")
                Text("\(likes)")
                Spacer().frame(width: 20)
                Image(systemName: "message")
                Text("\(comments)")
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
}
