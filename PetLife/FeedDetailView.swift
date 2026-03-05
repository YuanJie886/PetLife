import SwiftUI

struct FeedDetailView: View {
    var post: FeedPost // 接收传过来的动态数据
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // 用户信息栏
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                    
                    VStack(alignment: .leading) {
                        Text("宠萌用户").font(.subheadline).fontWeight(.bold)
                        Text(post.timeAgo).font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // 大图展示
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: post.imageUrl)
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    )
                
                // 文字内容
                Text(post.content)
                    .font(.body)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .lineSpacing(5)
                    .padding(.horizontal)
                
                // 互动数据
                HStack {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("\(post.likes) 次赞")
                    Spacer().frame(width: 20)
                    Image(systemName: "message.fill").foregroundColor(.gray)
                    Text("\(post.comments) 条评论")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            }
            .padding(.top)
        }
        .navigationTitle("动态详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
