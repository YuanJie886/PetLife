import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack(alignment: .top) {
            // 底色
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            // 顶部暖色背景卡片
            Color(red: 1.0, green: 0.88, blue: 0.71)
                .frame(height: 220)
                .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0) {
                // 1. 用户信息区
                HStack(spacing: 15) {
                    // 头像
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray.opacity(0.3))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("心恬的铲屎日记")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                        Text("ID: 88521099")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.top, 60)
                
                // 2. 数据统计悬浮卡片
                HStack {
                    ProfileStatItem(value: "12", title: "关注")
                    Divider().frame(height: 30)
                    ProfileStatItem(value: "2.5k", title: "粉丝")
                    Divider().frame(height: 30)
                    ProfileStatItem(value: "156", title: "获赞")
                }
                .padding(.vertical, 15)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, 25)
                
                // 3. 菜单列表区
                VStack(spacing: 15) {
                    ProfileMenuRow(icon: "heart.fill", iconColor: .orange, title: "我的收藏")
                    ProfileMenuRow(icon: "checkmark.calendar", iconColor: .green, title: "训练记录")
                    ProfileMenuRow(icon: "creditcard.fill", iconColor: .blue, title: "订单管理")
                    ProfileMenuRow(icon: "gearshape.fill", iconColor: .purple, title: "通用设置")
                }
                .padding(.top, 30)
                
                Spacer()
                
                // 4. 退出登录按钮
                Button(action: {
                    print("点击退出登录")
                }) {
                    Text("退出登录")
                        .font(.headline)
                        .foregroundColor(.red.opacity(0.7))
                        .padding(.bottom, 40)
                }
            }
        }
    }
}

// 子组件：统计项
struct ProfileStatItem: View {
    let value: String
    let title: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.headline).fontWeight(.bold)
            Text(title).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// 子组件：菜单行
struct ProfileMenuRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
                .font(.system(size: 14))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProfileView()
}
