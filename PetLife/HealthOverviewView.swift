import SwiftUI

struct HealthOverviewView: View {
    // 隐藏系统自带的返回按钮，使用我们自定义的顶部
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. 自定义顶部导航栏
                    HStack {
                        Button(action: {
                            dismiss() // 点击返回上一页
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                        }
                        
                        Text("健康概览")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 2. 体重趋势图表卡片
                    WeightChartCard()
                    
                    // 3. 饮水量与卡路里卡片
                    HStack(spacing: 15) {
                        SmallStatCard(icon: "cup.and.saucer.fill", iconColor: .green, title: "饮水量", value: "450ml", bgColor: Color(red: 0.92, green: 0.96, blue: 0.92))
                        SmallStatCard(icon: "dumbbell.fill", iconColor: .orange, title: "卡路里", value: "1.2k", bgColor: Color(red: 1.0, green: 0.96, blue: 0.89))
                    }
                    .padding(.horizontal)
                    
                    // 4. 下次提醒列表
                    ReminderListCard()
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationBarHidden(true) // 隐藏系统默认导航栏
    }
}

// MARK: - 子组件：体重趋势图表
struct WeightChartCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("体重趋势(kg)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
            
            // 模拟图表区域
            ZStack {
                // 背景网格线
                VStack(spacing: 15) {
                    ForEach((0..<7).reversed(), id: \.self) { i in
                        HStack {
                            Text("\(i * 3)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(width: 20, alignment: .trailing)
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                        }
                    }
                }
                
                // 模拟折线
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 15))
                    path.addLine(to: CGPoint(x: 80, y: 12))
                    path.addLine(to: CGPoint(x: 140, y: 16))
                    path.addLine(to: CGPoint(x: 200, y: 10))
                    path.addLine(to: CGPoint(x: 260, y: 12))
                    path.addLine(to: CGPoint(x: 320, y: 8))
                }
                .stroke(Color(red: 0.98, green: 0.69, blue: 0.29), lineWidth: 3)
                
                // 模拟渐变填充
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 15))
                    path.addLine(to: CGPoint(x: 80, y: 12))
                    path.addLine(to: CGPoint(x: 140, y: 16))
                    path.addLine(to: CGPoint(x: 200, y: 10))
                    path.addLine(to: CGPoint(x: 260, y: 12))
                    path.addLine(to: CGPoint(x: 320, y: 8))
                    path.addLine(to: CGPoint(x: 320, y: 100))
                    path.addLine(to: CGPoint(x: 30, y: 100))
                }
                .fill(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.0)]), startPoint: .top, endPoint: .bottom))
                
                // 悬浮提示框
                VStack(alignment: .leading, spacing: 4) {
                    Text("01.22")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        Circle().fill(Color.orange).frame(width: 8, height: 8)
                        Text("体重")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("15.4")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                .offset(x: -10, y: -20)
            }
            .frame(height: 120)
            
            // 底部日期
            HStack {
                Text("01.20").frame(maxWidth: .infinity)
                Text("01.22").frame(maxWidth: .infinity)
                Text("01.24").frame(maxWidth: .infinity)
                Text("01.26").frame(maxWidth: .infinity)
                Text("01.28").frame(maxWidth: .infinity)
                Text("01.29").frame(maxWidth: .infinity)
            }
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.leading, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - 子组件：小型数据卡片
struct SmallStatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let bgColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(bgColor)
        .cornerRadius(20)
    }
}

// MARK: - 子组件：提醒列表卡片
struct ReminderListCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("下次提醒")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
            
            ReminderRow(icon: "syringe.fill", iconBg: Color.red.opacity(0.1), iconColor: .red, title: "狂犬疫苗", date: "2026-02-15 · 宠物医院")
            
            ReminderRow(icon: "sparkles", iconBg: Color.blue.opacity(0.1), iconColor: .blue, title: "驱虫提醒", date: "2026-02-05 · 居家进行")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct ReminderRow: View {
    let icon: String
    let iconBg: Color
    let iconColor: Color
    let title: String
    let date: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().fill(iconBg).frame(width: 45, height: 45)
                Image(systemName: icon).foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

#Preview {
    HealthOverviewView()
}
