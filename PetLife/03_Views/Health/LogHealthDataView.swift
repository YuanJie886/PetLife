import SwiftUI

struct LogHealthDataView: View {
    @Environment(\.dismiss) var dismiss
    // 👇 1. 引入全局 ViewModel，这样才能修改数据
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var weight: String = ""
    @State private var waterIntake: String = ""
    // 💡 考虑到你之前的模型修改，我们把卡路里改成了更有趣的“心情状态”
    @State private var selectedStatus: String = "活泼"
    
    let statusOptions = ["活泼", "安静", "调皮", "想睡觉", "生病中"]
    
    var body: some View {
        NavigationView {
            Form {
                // --- 第一部分：数值输入 ---
                Section(header: Text("今日健康指标").foregroundColor(.gray)) {
                    HStack {
                        Image(systemName: "scalemass.fill").foregroundColor(.orange)
                        Text("体重 (kg)")
                        Spacer()
                        TextField("例如: 4.5", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Image(systemName: "drop.fill").foregroundColor(.cyan)
                        Text("饮水量 (ml)")
                        Spacer()
                        TextField("例如: 200", text: $waterIntake)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // --- 第二部分：状态选择 ---
                Section(header: Text("此刻状态").foregroundColor(.gray)) {
                    Picker("宠物状态", selection: $selectedStatus) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("记录日常")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveDataToViewModel()
                    }
                    .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // 💡 核心逻辑：将数据同步到本地、更新当前状态云端、并存入历史记录子集合
        private func saveDataToViewModel() {
            // 1. 安全地转换输入数据
            let newWeight = Double(weight) ?? viewModel.myPet.weight
            let newWater = Int(waterIntake) ?? viewModel.myPet.waterIntake
            
            // 2. 更新本地视图数据（即时反馈给 UI）
            viewModel.myPet.weight = newWeight
            viewModel.myPet.waterIntake = newWater
            viewModel.myPet.status = selectedStatus
            
            // 3. ⚡️ 同步到云端 - 覆盖“当前宠物档案”（用于首页看板）
            viewModel.savePetProfileToCloud()
            
            // 4. 📈 同步到云端 - 存入“历史记录子集合”（用于折线图）
            // 这一步非常重要，它会在 health_logs 集合里创建一条新数据
            viewModel.saveDailyLog(weight: newWeight, water: newWater)
            
            print("✅ 数据已同步！当前状态已更新，历史记录已追加。")
            
            dismiss()
        }
}
