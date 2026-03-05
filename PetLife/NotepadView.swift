import SwiftUI

struct NotepadView: View {
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 15) {
                    // 模拟的日记数据
                    DiaryCard(date: "10月24日", week: "星期二", mood: "sun.max.fill", moodColor: .orange, content: "今天给布丁洗了澡，它非常乖，没有闹腾！奖励了一个大罐头。🥩")
                    
                    DiaryCard(date: "10月20日", week: "星期五", mood: "cloud.rain.fill", moodColor: .blue, content: "下雨天，布丁一整天都在睡懒觉，发现它有一点挑食，明天开始尝试换一下猫粮的牌子。")
                    
                    DiaryCard(date: "10月15日", week: "星期日", mood: "heart.fill", moodColor: .red, content: "带去打了今年的狂犬疫苗，体重涨了0.5kg，医生说是个健康的胖小子！")
                }
                .padding()
            }
        }
        .navigationTitle("宠物记事本")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // 右上角写日记的按钮
                Button(action: { print("写新日记") }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                }
            }
        }
    }
}

// 日记卡片子组件
struct DiaryCard: View {
    let date: String
    let week: String
    let mood: String
    let moodColor: Color
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                Text(week)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: mood)
                    .foregroundColor(moodColor)
            }
            
            Divider()
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        NotepadView()
    }
}
