//
//  AddReminderView.swift
//  PetLife
//
//  Created by lhz on 2026/3/6.
//

import Foundation
import SwiftUI

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    
    // 👇 接住刚刚在 App 顶层注入的全局 ViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var title: String = ""
    @State private var location: String = ""
    
    // 默认“本次打针时间”为今天
    @State private var lastActionDate: Date = Date()
    
    // 默认“下次提醒时间”为一个月后 (86400秒 * 30天)
    @State private var nextReminderDate: Date = Date().addingTimeInterval(86400 * 30)
    
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
            .navigationTitle("添加提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("取消") {dismiss()}
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("保存"){
                        //智能判断一下：如果标题包含"疫苗"，就用红色的针筒图标，否则用蓝色的星星图标
                        let isVaccine = title.contains("疫苗")
                        let newReminder = PetReminder(
                            title: title.isEmpty ? "未命名项目" : title,
                            lastActionDate: lastActionDate,
                            nextReminderDate: nextReminderDate,
                            locationOrNote: location.isEmpty ? "无备注" : location,
                            icon: isVaccine ? "syringe.fill" : "sparkles",
                            iconColorName: isVaccine ? "red" : "blue"
                        )
                        
                        // 把之前的 reminders.append 删掉，换成呼叫 ViewModel 上传数据！
                        appViewModel.saveReminderToCloud(reminder: newReminder)
                        
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                    .fontWeight(.bold)
                }
            }
        }
    }
}
