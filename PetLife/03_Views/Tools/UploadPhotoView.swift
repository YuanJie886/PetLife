import SwiftUI
import PhotosUI

struct UploadPhotoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    var albumId: String
    
    // 图片选择
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var isUploading: Bool = false
    
    @State private var photoTitle = ""
    @State private var isPostValid: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // 图片选择区域
                    VStack(alignment: .leading, spacing: 10) {
                        if let image = selectedUIImage {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .foregroundColor(.white)
                                            )
                                            .onTapGesture {
                                                selectedUIImage = nil
                                                selectedItem = nil
                                                updateValidity()
                                            }
                                            .padding()
                                    }
                                    Spacer()
                                }
                            }
                        } else {
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 300)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                                        Text("点击选择照片")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedUIImage = uiImage
                                        updateValidity()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 照片描述
                    VStack(alignment: .leading, spacing: 4) {
                        Text("照片描述 (可选)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        TextField("记录这一刻...", text: $photoTitle)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // 发布按钮
                    Button(action: {
                        if !isUploading {
                            uploadPhoto()
                        }
                    }) {
                        HStack {
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                                Text("正在上传...")
                            } else {
                                Text("保存照片")
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
                    .disabled(!isPostValid || isUploading)
                }
                .padding(.top, 20)
            }
            .navigationTitle("上传照片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                }
            }
        }
    }
    
    private func updateValidity() {
        isPostValid = (selectedUIImage != nil)
    }
    
    private func uploadPhoto() {
        guard let image = selectedUIImage else { return }
        isUploading = true
        
        appViewModel.uploadImageToStorage(image: image) { url in
            DispatchQueue.main.async {
                if let imageUrl = url {
                    let newPhoto = PetPhoto(
                        id: nil,
                        albumId: albumId,
                        title: photoTitle.isEmpty ? "未命名照片" : photoTitle,
                        imageUrl: imageUrl,
                        createdAt: Date()
                    )
                    appViewModel.savePhotoToCloud(photo: newPhoto)
                } else {
                    print("❌ 图片上传失败")
                }
                isUploading = false
                dismiss()
            }
        }
    }
}

// 照片详情视图(支持修改描述和删除)
struct PhotoDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State var photo: PetPhoto
    
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    AsyncImage(url: URL(string: photo.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // 底部描述区域
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            if isEditing {
                                TextField("编辑描述", text: $editedTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.black)
                                    .padding(.trailing, 10)
                                
                                Button("保存") {
                                    photo.title = editedTitle
                                    appViewModel.updatePhoto(photo: photo)
                                    isEditing = false
                                }
                                .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                                .fontWeight(.bold)
                            } else {
                                Text(photo.title)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(action: {
                                    editedTitle = photo.title
                                    isEditing = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                                }
                            }
                        }
                        
                        Text("上传于 \(formatDate(photo.createdAt))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(15)
                    .padding()
                }
            }
            .navigationTitle("照片详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            // 使用 iOS 15 的 alert，iOS 17 支持但会报 warning，项目中为了适配通常会保持
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("确认删除照片？"),
                    message: Text("删除后将无法恢复，确定要删除这张照片吗？"),
                    primaryButton: .destructive(Text("删除")) {
                        appViewModel.deletePhoto(photo: photo)
                        dismiss()
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    UploadPhotoView(albumId: "dummy_album_id")
        .environmentObject(AppViewModel())
}
