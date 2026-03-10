import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var showingCreateAlbumSheet = false
    @State private var newAlbumTitle = ""
    
    // 定义两列网格布局
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    let defaultColors: [Color] = [
        Color(red: 1.0, green: 0.96, blue: 0.94),
        Color(red: 0.96, green: 0.97, blue: 1.0),
        Color(red: 0.96, green: 0.91, blue: 0.96)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    
                    // 新建相册按钮
                    Button(action: {
                        showingCreateAlbumSheet = true
                    })
                    {
                        VStack {
                            Rectangle()
                                .fill(Color(red: 0.91, green: 0.96, blue: 0.91))
                                .aspectRatio(1, contentMode: .fill)
                                .cornerRadius(20)
                                .overlay(
                                    Image(systemName: "folder.badge.plus")
                                        .font(.system(size: 40, weight: .light))
                                        .foregroundColor(.gray.opacity(0.5))
                                )
                            Text("新建相册")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // 循环显示云端的相册
                    ForEach(Array(appViewModel.petAlbums.enumerated()), id: \.element.id) { index, album in
                        NavigationLink(destination: AlbumPhotosView(albumId: album.id ?? "", albumTitle: album.title).environmentObject(appViewModel)) {
                            AlbumCard(album: album, bgColor: defaultColors[index % defaultColors.count])
                        }
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
                Button(action: { showingCreateAlbumSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                }
            }
        }
        .sheet(isPresented: $showingCreateAlbumSheet) {
            // 新建相册弹窗
            NavigationView {
                Form {
                    Section(header: Text("相册名称")) {
                        TextField("给相册起个名字吧...", text: $newAlbumTitle)
                    }
                    
                    Button(action: {
                        if !newAlbumTitle.isEmpty {
                            appViewModel.saveAlbumToCloud(title: newAlbumTitle)
                            newAlbumTitle = ""
                            showingCreateAlbumSheet = false
                        }
                    }) {
                        Text("创建相册")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(newAlbumTitle.isEmpty ? .gray : .blue)
                    }
                    .disabled(newAlbumTitle.isEmpty)
                }
                .navigationTitle("新建相册")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("取消") {
                            showingCreateAlbumSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.height(250)])
        }
        .onAppear {
            appViewModel.fetchAlbumsFromCloud()
        }
    }
}

// 子组件：相册卡片封面
struct AlbumCard: View {
    let album: PetAlbum
    let bgColor: Color
    
    var body: some View {
        VStack {
            if let coverUrl = album.coverImageUrl {
                AsyncImage(url: URL(string: coverUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(bgColor)
                            .aspectRatio(1, contentMode: .fill)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(bgColor)
                            .aspectRatio(1, contentMode: .fill)
                            .overlay(Image(systemName: "photo.on.rectangle").foregroundColor(.gray.opacity(0.5)))
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(20)
                .clipped()
            } else {
                Rectangle()
                    .fill(bgColor)
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(20)
                    .overlay(
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundColor(.black.opacity(0.05))
                    )
            }
            
            Text(album.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                .lineLimit(1)
        }
    }
}

#Preview {
    NavigationView {
        AlbumView()
            .environmentObject(AppViewModel())
    }
}
