import SwiftUI
import Charts // 导入系统框架

struct HealthOverviewView: View {
    // 隐藏系统自带的返回按钮，使用我们自定义的顶部
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showLogDataSheet: Bool = false
    @State private var showAddReminderSheet: Bool = false
    
    // 使用全局的 ViewModel 获取提醒事项数据

    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 自定义顶部导航栏
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
                    
                    // 体重趋势图表卡片
                    WeightChartCard()
                    
                    // 饮水量与卡路里卡片
                    HStack(spacing: 15) {
                        // 绑定真实饮水量
                        SmallStatCard(
                            icon: "drop.fill",
                            iconColor: .cyan,
                            title: "今日饮水",
                            value: "\(appViewModel.myPet.waterIntake)ml",
                            bgColor: Color(red: 0.92, green: 0.96, blue: 0.98)
                        )
                        
                        // 绑定真实宠物状态（因为你之前删了卡路里，这里展示状态更符合逻辑）
                        SmallStatCard(
                            icon: "face.smiling.fill",
                            iconColor: .orange,
                            title: "当前状态",
                            value: appViewModel.myPet.status,
                            bgColor: Color(red: 1.0, green: 0.96, blue: 0.89)
                        )
                    }
                    .padding(.horizontal)
                    
                    // 下次提醒列表
                    ReminderListCard(reminders: appViewModel.myReminders) {
                        showAddReminderSheet = true // 点击加号触发的操作
                    }
                    
                    Button(action: {
                        showLogDataSheet = true
                    }) {
                        HStack(spacing: 10){
                            Image(systemName:"plus.circle.fill").font(.title2)
                            Text("记录今日宠物数据")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.98, green: 0.69, blue: 0.29)) // 使用你的主题亮橙色
                        .cornerRadius(20)
                        .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationBarHidden(true) // 隐藏系统默认导航栏
        .sheet(isPresented: $showAddReminderSheet) {
            AddReminderView()
                .environmentObject(appViewModel) // 👈 传递环境对象
        }
        .sheet(isPresented: $showLogDataSheet){
            LogHealthDataView()
        }
        .onAppear {
            // 1. 拉取提醒
            appViewModel.fetchRemindersFromCloud()
            appViewModel.fetchHealthHistory()
            // 2. 拉取宠物档案 (确保你在 AppViewModel 实现了这个方法)
            appViewModel.fetchPetProfileFromCloud()
        }
    }
}

// MARK: - 子组件：体重趋势图表
struct WeightChartCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("体重趋势 (kg)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
            
            if appViewModel.healthHistory.isEmpty {
                // 数据加载中的占位提示
                ContentUnavailableView("暂无历史数据", systemImage: "chart.line.uptrend.xyaxis", description: Text("开始记录你的宠物体重吧"))
                    .frame(height: 150)
            } else {
                // 👇 核心：动态折线图
                Chart {
                    ForEach(appViewModel.healthHistory) { record in
                        // 1. 绘制折线
                        LineMark(
                            x: .value("日期", record.date, unit: .day),
                            y: .value("体重", record.weight)
                        )
                        .interpolationMethod(.catmullRom) // 让线条变圆润
                        .foregroundStyle(Color.orange)
                        
                        // 2. 绘制数据点
                        PointMark(
                            x: .value("日期", record.date, unit: .day),
                            y: .value("体重", record.weight)
                        )
                        .foregroundStyle(Color.orange)
                    }
                }
                .frame(height: 150)
                // 设置坐标轴样式
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.month(.twoDigits).day(.twoDigits))
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false)) // 自动缩放 Y 轴，不强制从 0 开始，折线波动更明显
            }
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
    // 接收外部传来的提醒列表
    var reminders: [PetReminder]
    // 点击添加按钮的闭包
    var onAddClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("下次提醒")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                
                Spacer()
                
                // 添加提醒的小按钮
                Button(action: onAddClick) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                        .font(.title3)
                }
            }
            
            if reminders.isEmpty {
                Text("暂无提醒事项，毛孩子最近很健康哦！")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                // 遍历真实数据
                ForEach(reminders) { reminder in
                    ReminderRow(
                        icon: reminder.icon,
                        iconBg: reminder.iconColor.opacity(0.1),
                        iconColor: reminder.iconColor,
                        title: reminder.title,
                        date: reminder.displayDateString
                    )
                }
            }
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
        .environmentObject(AppViewModel())
}
