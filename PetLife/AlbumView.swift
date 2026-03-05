import SwiftUI

struct AlbumView: View {
    // 定义两列网格布局
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    // 相册 1
                    AlbumCard(title: "成长足迹", bgColor: Color(red: 1.0, green: 0.96, blue: 0.94))
                    // 相册 2
                    AlbumCard(title: "外出的快乐", bgColor: Color(red: 0.96, green: 0.97, blue: 1.0))
                    // 相册 3
                    AlbumCard(title: "睡姿百态", bgColor: Color(red: 0.96, green: 0.91, blue: 0.96))
                    
                    // 新建相册按钮
                    VStack {
                        Rectangle()
                            .fill(Color(red: 0.91, green: 0.96, blue: 0.91))
                            .aspectRatio(1, contentMode: .fill)
                            .cornerRadius(20)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                        Text("创建新相册")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("宠物相册")
        .navigationBarTitleDisplayMode(.inline)
        // 右上角的加号
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { print("添加照片") }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                }
            }
        }
    }
}

// 子组件：相册卡片
struct AlbumCard: View {
    let title: String
    let bgColor: Color
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(bgColor)
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(20)
                // 模拟里面有照片的图标占位
                .overlay(
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle)
                        .foregroundColor(.black.opacity(0.05))
                )
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
        }
    }
}

#Preview {
    NavigationView {
        AlbumView()
    }
}
