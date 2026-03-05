import SwiftUI

struct PublishPostView: View {
    @Environment(\.dismiss) var dismiss // 用于关闭当前弹窗
    @State private var postText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $postText)
                    .frame(height: 150)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .padding()
                
                HStack {
                    Button(action: {}) {
                        Image(systemName: "photo.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("发布新动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() } // 点击取消关闭页面
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("发布") {
                        print("发布内容: \(postText)")
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
