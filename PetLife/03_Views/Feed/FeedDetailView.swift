import SwiftUI

struct FeedDetailView: View {
    var post: FeedPost // 接收传过来的动态数据
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // 用户信息栏
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.91, blue: 0.74))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: post.authorAvatar)
                            .font(.title3)
                            .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                    }
                    
                    VStack(alignment: .leading) {
                        Text(post.authorName).font(.subheadline).fontWeight(.bold)
                        Text(post.timeAgo).font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // 大图展示
                Group {
                    if post.imageUrl.starts(with: "http") {
                        AsyncImage(url: URL(string: post.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 300)
                                    .background(Color.gray.opacity(0.1))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.05))
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .background(Color.gray.opacity(0.15))
                            @unknown default:
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .background(Color.gray.opacity(0.15))
                            }
                        }
                    } else if UIImage(named: post.imageUrl) != nil {
                        Image(post.imageUrl)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.05))
                    } else if !post.imageUrl.isEmpty {
                        Image(systemName: post.imageUrl)
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .background(Color.gray.opacity(0.15))
                    }
                }
                
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
