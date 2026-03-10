//
//  LogHealthDataView.swift
//  PetLife
//
//  Created by lhz on 2026/3/6.
//

import SwiftUI

// MARK: - 新增的子页面：记录健康数据表单
struct LogHealthDataView: View {
    @Environment(\.dismiss) var dismiss // 用于关闭弹窗
    
    // 绑定输入框的变量
    @State private var weight: String = ""
    @State private var waterIntake: String = ""
    @State private var calories: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("今日健康指标").foregroundColor(.gray)) {
                    // 体重输入
                    HStack {
                        Image(systemName: "scalemass.fill").foregroundColor(.orange)
                        Text("体重 (kg)")
                        Spacer()
                        TextField("例如: 15.5", text: $weight)
                            .keyboardType(.decimalPad) // 调出带小数点的数字键盘
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // 饮水量输入
                    HStack {
                        Image(systemName: "drop.fill").foregroundColor(.cyan)
                        Text("饮水量 (ml)")
                        Spacer()
                        TextField("例如: 450", text: $waterIntake)
                            .keyboardType(.numberPad) // 调出纯数字键盘
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // 卡路里输入
                    HStack {
                        Image(systemName: "flame.fill").foregroundColor(.red)
                        Text("消耗热量 (kcal)")
                        Spacer()
                        TextField("例如: 1200", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("记录日常")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // 💡 之后有了数据库，这里就是把 weight 和 waterIntake 存入后端的代码
                        print("保存成功: 体重 \(weight)kg, 饮水 \(waterIntake)ml")
                        dismiss() // 保存后关闭页面
                    }
                    .foregroundColor(Color(red: 0.98, green: 0.69, blue: 0.29))
                    .fontWeight(.bold)
                }
            }
        }
    }
}
