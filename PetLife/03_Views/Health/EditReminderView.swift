import Foundation
import SwiftUI

struct EditReminderView: View {
    @Environment(\.dismiss) var dismiss
    
    // 👇 接住刚刚在 App 顶层注入的全局 ViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    // 接受传入的提醒事项
    var reminder: PetReminder
    
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var lastActionDate: Date = Date()
    @State private var nextReminderDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form{
                Section(header: Text("提醒内容")){
                    TextField("项目名称(例如:狂犬疫苗)",text: $title)
                    TextField("备注/地点 (例如: 宠物医院)", text: $location)
                }
                
                Section(header:Text("时间设置")){
                    // 记录本次打针的时间
                    DatePicker("本次记录时间", selection: $lastActionDate, displayedComponents: .date)
                    // 设置下次需要提醒的时间
                    DatePicker("下次提醒时间", selection: $nextReminderDate, displayedComponents: .date)
                }
            }
            .navigationTitle("编辑提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("取消") {dismiss()}
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("保存"){
                        let isVaccine = title.contains("疫苗")
                        
                        var updatedReminder = reminder
                        updatedReminder.title = title.isEmpty ? "未命名项目" : title
                        updatedReminder.locationOrNote = location.isEmpty ? "无备注" : location
                        updatedReminder.lastActionDate = lastActionDate
                        updatedReminder.nextReminderDate = nextReminderDate
                        updatedReminder.icon = isVaccine ? "syringe.fill" : "sparkles"
                        updatedReminder.iconColorName = isVaccine ? "red" : "blue"
                        
                        appViewModel.updateReminderInCloud(reminder: updatedReminder)
                        
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                self.title = reminder.title
                self.location = reminder.locationOrNote
                self.lastActionDate = reminder.lastActionDate
                self.nextReminderDate = reminder.nextReminderDate
            }
        }
    }
}
