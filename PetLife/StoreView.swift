import SwiftUI

struct StoreView: View {
    // 模拟两列网格布局
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // 顶部导航
                    HStack {
                        Text("宠物商城")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                        Spacer()
                        Image(systemName: "cart")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 新人福利 Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("新人福利")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("首次下单立减 20 元")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        // 占位图片
                        Image(systemName: "gift.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(20)
                    .background(Color(red: 0.98, green: 0.69, blue: 0.29)) // 橙黄色
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // 商品列表 Grid
                    LazyVGrid(columns: columns, spacing: 15) {
                        ProductCard(title: "全价成犬粮 5kg", price: "¥199")
                        ProductCard(title: "宠物专用护毛素", price: "¥329")
                        ProductCard(title: "宠物洗澡沐浴露", price: "¥29")
                        ProductCard(title: "营养伴食液", price: "¥139")
                    }
                    .padding(.horizontal)
                    
                    // 留出底部导航栏的空间
                    Spacer(minLength: 120)
                }
            }
        }
    }
}

// 子组件：商品卡片
struct ProductCard: View {
    let title: String
    let price: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 商品图占位
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(12)
                .overlay(Text("Product").foregroundColor(.gray))
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                .lineLimit(1)
            
            HStack {
                Text(price)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.35)) // 橘红色
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    StoreView()
}
