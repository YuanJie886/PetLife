import SwiftUI

struct WelcomeView: View {
    @State private var showHome = false
    
    var body: some View {
        ZStack {
            // 背景色 (米白色)
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // 顶部 Logo 圆圈
                ZStack {
                    Circle()
                        .fill(Color(red: 0.98, green: 0.69, blue: 0.29)) // 橙黄色
                        .frame(width: 100, height: 100)
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
                
                // 标题部分
                VStack(spacing: 12) {
                    Text("宠萌生活")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25)) // 深棕色
                    
                    Text("给毛孩子最温柔的陪伴")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 插画占位符 (后续在 Assets 中替换为你真实的图片)
                VStack {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Cute pet illustration")
                        .foregroundColor(.gray)
                }
                .frame(height: 200)
                
                Spacer()
                
                // 底部按钮
                Button(action: {
                    showHome = true
                    print("点击开始")
                }) {
                    Text("点击开始")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.98, green: 0.69, blue: 0.29))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showHome) {
            HomeView() // 跳转的目的地：主页
        }
    }
}

#Preview {
    WelcomeView()
}
