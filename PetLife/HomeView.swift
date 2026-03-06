import SwiftUI
struct HomeView: View {
    // 👇 1. 添加一个状态，记录当前选中的是哪个 Tab
    @State private var selectedTab: Int = 0
    @State private var showPublishSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 👇 2. 根据选中的 Tab，显示不同的页面
                Group {
                    if selectedTab == 0 {
                        HomeContentView() // 下面拆分出来的主页内容
                    } else if selectedTab == 1 {
                        StoreView()       // 商场
                    } else if selectedTab == 2 {
                        TrainingView()    // 训练
                    } else {
                        ProfileView()
                    }
                }
                
                // 👇 3. 把状态绑定给底部导航栏
                CustomTabBar(selectedTab: $selectedTab, onPublishClick: {
                                    showPublishSheet = true
                                })
            }
        }
        .sheet(isPresented: $showPublishSheet) {
                    PublishPostView()
                }
    }
}

struct DynamicFeedCard: View {
    var post: FeedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 👇 核心修改：替换原来的占位图逻辑，支持三种图片类型
            Group {
                // 1. 网络图片（以 http/https 开头）
                if post.imageUrl.starts(with: "http") {
                    AsyncImage(url: URL(string: post.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            // 加载中显示进度条
                            ProgressView()
                                .frame(height: 180)
                        case .success(let image):
                            // 加载成功显示图片
                            image
                                .resizable()
                                .scaledToFill() // 保持比例填充
                                .frame(height: 180)
                                .clipped() // 裁剪超出部分
                        case .failure:
                            // 加载失败显示占位图标
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .frame(height: 180)
                        @unknown default:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .frame(height: 180)
                        }
                    }
                }
                // 2. 本地图片（Assets 里的图片，不是系统图标）
                else if UIImage(named: post.imageUrl) != nil {
                    Image(post.imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                }
                // 3. 系统图标（兜底，比如你传的 camera.macro）
                else {
                    Image(systemName: post.imageUrl)
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(height: 180)
                }
            }
            .cornerRadius(15) // 保持原来的圆角
            
            // 👇 以下部分完全保留你的原有代码
            Text(post.content)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            
            HStack {
                Image(systemName: "heart").foregroundColor(.gray)
                Text("\(post.likes)").font(.caption).foregroundColor(.gray)
                Spacer().frame(width: 15)
                Image(systemName: "message").foregroundColor(.gray)
                Text("\(post.comments)").font(.caption).foregroundColor(.gray)
                Spacer()
                Text(post.timeAgo).font(.caption).foregroundColor(.gray)
            }
        }
        .padding().background(Color.white).cornerRadius(20).padding(.horizontal)
    }
}

struct DynamicPetInfoCard: View {
    var pet: PetProfile // 👈 接收外部传进来的宠物数据
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "cat.fill").foregroundColor(.orange))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(pet.name) (\(pet.breed))") // 使用真实数据
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("今天状态: \(pet.status)") // 使用真实数据
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                NavigationLink(destination: HealthOverviewView()) {
                    Text("详情")
                        .font(.caption)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(15)
                }
            }
            
            HStack {
                // 👇 把这三个 StatItem 改成 StatBox 就可以了！
                StatBox(title: "步数", value: "\(pet.steps)")
                Spacer()
                StatBox(title: "热量", value: "\(pet.calories)")
                Spacer()
                StatBox(title: "睡眠", value: "\(pet.sleepHours)h")
            }
        }
        .padding()
        .background(Color(red: 1.0, green: 0.91, blue: 0.74))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}


struct HomeContentView: View {
    // 👇 1. 请入我们的数据管家
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HStack {
                        Text("主页").font(.title2).fontWeight(.bold).foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                        Spacer()
                        Image(systemName: "bell").font(.title2).foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                    }
                    .padding(.horizontal).padding(.top, 10)
                    
                    // 👇 2. 把真实数据传给宠物卡片
                    DynamicPetInfoCard(pet: viewModel.myPet)
                    
                    QuickActionsView()
                    
                    // 👇 3. 把动态列表改成遍历真实数据
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("热门动态")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            NavigationLink(destination: CommunityView()) {
                                    Text("查看更多")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.hotFeeds.isEmpty {
                            // 数据还在加载中时显示个菊花圈
                            ProgressView("正在加载动态...").frame(maxWidth: .infinity)
                        } else {
                            // 遍历渲染真实数据
                            ForEach(viewModel.hotFeeds) { post in
                                        // 👇 修改这里：给动态卡片包上一层 NavigationLink
                                        NavigationLink(destination: FeedDetailView(post: post)) {
                                            DynamicFeedCard(post: post)
                                        }
                                        // 防止整个卡片被 NavigationLink 渲染成蓝色高亮
                                        .buttonStyle(PlainButtonStyle())
                                    }
                        }
                    }
                    
                    Spacer(minLength: 120)
                }
            }
        }
        // 👇 4. 页面出现的时候，让管家去拉取数据
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int // 接收外部传来的状态
    var onPublishClick: () -> Void
    
    
    var body: some View {
        HStack {
            TabBarIcon(iconName: "house.fill", title: "首页", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarIcon(iconName: "storefront.fill", title: "商城", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            // 中间悬浮加号按钮
            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.69, blue: 0.29))
                    .frame(width: 65, height: 65)
                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.semibold)
            }
            .offset(y: -20)
            .onTapGesture {
                onPublishClick()
            }
            
            TabBarIcon(iconName: "puzzlepiece.fill", title: "训练", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabBarIcon(iconName: "person.fill", title: "我的", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 25)
        // 👇 核心修改在这里：去掉纯白背景，换成极致轻薄的毛玻璃材质
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .opacity(0.7)   // 👈 提高透明度
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: -5) // 修改为更柔和的暗色阴影让玻璃更凸显
        .edgesIgnoringSafeArea(.bottom)
    }
}
// MARK: - 子组件：宠物状态卡片
struct PetInfoCard: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                // 头像占位
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "cat.fill").foregroundColor(.orange))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("布丁 (布偶)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    Text("今天状态: 活泼")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                NavigationLink(destination: HealthOverviewView()){
                Text("详情")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(15)
                }
            }
            
            HStack(spacing: 15) {
                StatBox(title: "步数", value: "5240")
                StatBox(title: "热量", value: "320")
                StatBox(title: "睡眠", value: "9h")
            }
        }
        .padding()
        .background(Color(red: 1.0, green: 0.91, blue: 0.74)) // 卡片背景色
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundColor(.gray)
            Text(value).font(.headline).fontWeight(.bold).foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }
}

struct TabBarIcon: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void // 增加点击闭包
    
    var body: some View {
        Spacer()
        VStack(spacing: 5) {
            Image(systemName: iconName)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? Color(red: 0.98, green: 0.69, blue: 0.29) : .gray.opacity(0.6))
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? Color(red: 0.98, green: 0.69, blue: 0.29) : .gray)
        }
        .contentShape(Rectangle()) // 扩大点击区域
        .onTapGesture {
            action() // 执行点击动作
        }
        Spacer()
    }
}
// MARK: - 子组件：快捷功能区
struct QuickActionsView: View {
    var body: some View {
        HStack {
            Spacer()
            
            // 1. 记事本：跳转到新页面
            NavigationLink(destination: NotepadView()) {
                ActionIcon(icon: "apple.logo", title: "记事本", color: .orange)
            }
            Spacer()
            
            // 2. 相册：跳转到我们之前写好的 AlbumView
            NavigationLink(destination: AlbumView()) {
                ActionIcon(icon: "camera.fill", title: "相册", color: .green)
            }
            Spacer()
            
            // 3. 商城：可以直接发个通知切换底部的 Tab，这里先做个简单的点击响应
            Button(action: { print("点击了商城") }) {
                ActionIcon(icon: "gift.fill", title: "商城", color: .purple)
            }
            Spacer()
            
            // 4. 分析：暂不实现功能，点击打印一下
            Button(action: { print("分析功能暂不实现") }) {
                ActionIcon(icon: "chart.line.uptrend.xyaxis", title: "分析", color: .blue)
            }
            Spacer()
        }
        .padding(.horizontal, 5)
    }
}

// 抽取出来的小组件，让代码更干净
struct ActionIcon: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .shadow(color: .gray.opacity(0.08), radius: 5, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            Text(title)
                .font(.caption)
                // 强制文字颜色，防止被 NavigationLink 变成系统默认的蓝色
                .foregroundColor(.gray)
        }
    }
}

// MARK: - 子组件：热门动态卡片
struct HotFeedView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("热门动态")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                Spacer()
                Text("查看更多")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                // 动态图片占位
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .cornerRadius(15)
                    .overlay(Text("展示猫咪的图片").foregroundColor(.gray))
                
                Text("今天的阳光真好，带布丁去公园撒欢啦! ☀️🐶")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "heart")
                    Text("128")
                    Spacer().frame(width: 20)
                    Image(systemName: "message")
                    Text("12")
                    Spacer()
                    Text("10分钟前")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal)
            .shadow(color: .gray.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    HomeView()
}
