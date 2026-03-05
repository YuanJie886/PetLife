import SwiftUI

struct TrainingView: View {
    var body: some View {
        ZStack {
            // 背景稍微偏冷一点点，更符合训练场景的清爽感
            Color(red: 0.98, green: 0.98, blue: 0.99).edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 顶部导航
                    HStack {
                        Text("训练中心")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                        Spacer()
                        Image(systemName: "book.pages.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 今日进度卡片
                    VStack(alignment: .leading, spacing: 15) {
                        Text("今日进度")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(alignment: .center, spacing: 15) {
                            Text("65%")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                            
                            // 自定义进度条
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule().frame(height: 10)
                                        .foregroundColor(Color.gray.opacity(0.2))
                                    Capsule().frame(width: geometry.size.width * 0.65, height: 10)
                                        .foregroundColor(Color.green.opacity(0.6))
                                }
                            }
                            .frame(height: 10)
                        }
                        
                        Text("再完成个“随行”训练即可达成今日目标！")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // 推荐课程列表
                    VStack(alignment: .leading, spacing: 15) {
                        Text("推荐课程")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                            .padding(.horizontal)
                        
                        CourseCard(icon: "dog.fill", iconBg: Color(red: 1.0, green: 0.95, blue: 0.85), iconColor: .orange, title: "基础坐下训练", desc: "3 节课时 · 难度 ⭐️", btnText: "去学习", isLocked: false)
                        
                        CourseCard(icon: "pawprint.fill", iconBg: Color(red: 0.96, green: 0.93, blue: 0.98), iconColor: .purple.opacity(0.5), title: "握手接球进阶", desc: "5 节课时 · 难度 ⭐️⭐️", btnText: "待解锁", isLocked: true)
                    }
                    
                    Spacer(minLength: 120)
                }
            }
        }
    }
}

// 子组件：课程卡片
struct CourseCard: View {
    let icon: String
    let iconBg: Color
    let iconColor: Color
    let title: String
    let desc: String
    let btnText: String
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(iconBg)
                    .frame(width: 70, height: 70)
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(btnText)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isLocked ? .white : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isLocked ? Color.gray.opacity(0.4) : Color(red: 0.98, green: 0.69, blue: 0.29))
                .cornerRadius(20)
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

#Preview {
    TrainingView()
}
