import SwiftUI

struct AlbumPhotosView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let albumId: String
    let albumTitle: String
    
    @State private var showingUploadSheet = false
    @State private var selectedPhoto: PetPhoto?
    
    // 定义两列网格布局
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            if appViewModel.petPhotos.isEmpty {
                VStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.bottom, 10)
                    Text("相册还没有照片哟")
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(appViewModel.petPhotos) { photo in
                            Button(action: {
                                selectedPhoto = photo
                            }) {
                                PhotoCard(photo: photo)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle(albumTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingUploadSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                }
            }
        }
        .onAppear {
            appViewModel.fetchPhotosFromCloud(albumId: albumId)
        }
        .sheet(isPresented: $showingUploadSheet) {
            UploadPhotoView(albumId: albumId)
                .environmentObject(appViewModel)
        }
        // 显示照片详情(支持修改描述和删除)
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo)
                .environmentObject(appViewModel)
        }
    }
}

// 子组件：照片卡片
struct PhotoCard: View {
    let photo: PetPhoto
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: photo.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(red: 0.96, green: 0.97, blue: 1.0))
                        .aspectRatio(1, contentMode: .fill)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color(red: 0.96, green: 0.91, blue: 0.96))
                        .aspectRatio(1, contentMode: .fill)
                        .overlay(Image(systemName: "photo").foregroundColor(.gray.opacity(0.5)))
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(20)
            .clipped()
            
            Text(photo.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                .lineLimit(1)
        }
    }
}

#Preview {
    NavigationView {
        AlbumPhotosView(albumId: "dummy_id", albumTitle: "未命名相册")
            .environmentObject(AppViewModel())
    }
}
