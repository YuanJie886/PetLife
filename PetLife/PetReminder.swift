import Foundation
import SwiftUI
import Combine          // 👈 加上这句，专门用来消灭 Combine 报错！
import FirebaseCore
import FirebaseFirestore

// 1. 定义提醒的数据结构
struct PetReminder: Identifiable, Codable {
    var id: String = UUID().uuidString    // 建议用 String 格式的 ID，Firebase 更喜欢
    var title: String             // 项目名称（如：狂犬疫苗）
    var lastActionDate: Date      // 本次记录时间（打针的时间）
    var nextReminderDate: Date    // 下次提醒时间
    var locationOrNote: String    // 地点或备注
    var icon: String              // 图标名
    var iconColorName: String     // 👈 变化在这里：把 Color 改成存颜色的名字(String)

    // 自动格式化要在列表里显示的文字
    var displayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: nextReminderDate)) · \(locationOrNote)"
    }
    
    // 👈 新增一个小魔法：自动把文字转换回颜色，供界面使用 (计算属性不会报错)
    var iconColor: Color {
        switch iconColorName {
        case "blue": return .blue
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "pink": return .pink
        default: return .gray
        }
    }
}
