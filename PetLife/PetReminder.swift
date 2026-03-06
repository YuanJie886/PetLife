import SwiftUI

// 1. 定义提醒的数据结构
struct PetReminder: Identifiable {
    let id = UUID()
    var title: String             // 项目名称（如：狂犬疫苗）
    var lastActionDate: Date      // 本次记录时间（打针的时间）
    var nextReminderDate: Date    // 下次提醒时间
    var locationOrNote: String    // 地点或备注
    var icon: String              // 图标名
    var iconColor: Color          // 图标颜色
    
    // 自动格式化要在列表里显示的文字
    var displayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: nextReminderDate)) · \(locationOrNote)"
    }
}
