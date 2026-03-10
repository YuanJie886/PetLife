import SwiftUI
import Foundation
import Combine
import FirebaseFirestore

struct PetNote: Identifiable, Codable {
    var id: String = UUID().uuidString
    var date: Date
    var mood: String
    var moodColorIndex: Int
    var content: String
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
    
    var weekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    var moodColor: Color {
        let colors: [Color] = [.orange, .blue, .red, .green, .purple]
        if moodColorIndex >= 0 && moodColorIndex < colors.count {
            return colors[moodColorIndex]
        }
        return .orange
    }
}

class NotepadViewModel: ObservableObject {
    @Published var notes: [PetNote] = []
    
    private var db = Firestore.firestore()
    
    init() {
        fetchNotesFromCloud()
    }
    
    func fetchNotesFromCloud() {
        db.collection("pet_notes")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ 获取日记失败: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                self.notes = documents.compactMap { try? $0.data(as: PetNote.self) }
                print("✅ 从云端拉取了 \(self.notes.count) 条日记")
            }
    }
    
    func addNote(content: String, mood: String, moodColorIndex: Int) {
        let newNote = PetNote(date: Date(), mood: mood, moodColorIndex: moodColorIndex, content: content)
        do {
            let noteRef = db.collection("pet_notes").document(newNote.id)
            try noteRef.setData(from: newNote)
            print("🚀 日记保存到云端成功！")
        } catch {
            print("❌ 保存日记失败: \(error.localizedDescription)")
        }
    }
    
    func updateNote(note: PetNote) {
        do {
            let noteRef = db.collection("pet_notes").document(note.id)
            try noteRef.setData(from: note)
            print("✏️ 日记更新到云端成功！")
        } catch {
            print("❌ 更新日记失败: \(error.localizedDescription)")
        }
    }
    
    func deleteNote(note: PetNote) {
        db.collection("pet_notes").document(note.id).delete { error in
            if let error = error {
                print("❌ 删除日记失败: \(error.localizedDescription)")
            } else {
                print("🗑️ 日记删除成功！")
            }
        }
    }
}

struct NotepadView: View {
    @StateObject private var viewModel = NotepadViewModel()
    @State private var showingAddSheet = false
    @State private var noteToEdit: PetNote?
    @State private var noteToDelete: PetNote?

    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            if viewModel.notes.isEmpty {
                VStack {
                    Image(systemName: "note.text")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("还没有日记\n点击右上角开始记录吧")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding()
                }
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.notes) { note in
                            DiaryCard(note: note, onEdit: {
                                noteToEdit = note
                            }, onDelete: {
                                noteToDelete = note
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("宠物记事本")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddNoteView(viewModel: viewModel)
        }
        .sheet(item: $noteToEdit) { note in
            EditNoteView(viewModel: viewModel, note: note)
        }
        .alert(item: $noteToDelete) { note in
            Alert(
                title: Text("确认删除"),
                message: Text("确定要删除这条日记吗？"),
                primaryButton: .destructive(Text("删除")) {
                    viewModel.deleteNote(note: note)
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
}

// 日记卡片子组件
struct DiaryCard: View {
    let note: PetNote
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.dateString)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.25))
                Text(note.weekString)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: note.mood)
                    .foregroundColor(note.moodColor)
                
                if onEdit != nil || onDelete != nil {
                    Menu {
                        if let onEdit = onEdit {
                            Button(action: onEdit) {
                                Label("编辑", systemImage: "pencil")
                            }
                        }
                        if let onDelete = onDelete {
                            Button(role: .destructive, action: onDelete) {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(.vertical)
                            .padding(.leading, 8)
                    }
                }
            }
            
            Divider()
            
            Text(note.content)
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

struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: NotepadViewModel
    
    @State private var content: String = ""
    @State private var selectedMood: String = "sun.max.fill"
    @State private var selectedColorIndex: Int = 0
    
    let moods = ["sun.max.fill", "cloud.fill", "cloud.rain.fill", "moon.stars.fill", "heart.fill"]
    let colors: [Color] = [.orange, .blue, .red, .green, .purple]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("今天心情")) {
                    HStack {
                        ForEach(0..<moods.count, id: \.self) { index in
                            Image(systemName: moods[index])
                                .font(.title2)
                                .foregroundColor(selectedMood == moods[index] ? colors[selectedColorIndex] : .gray.opacity(0.3))
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    selectedMood = moods[index]
                                    selectedColorIndex = index
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("日记内容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("写新日记")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    if !content.isEmpty {
                        viewModel.addNote(content: content, mood: selectedMood, moodColorIndex: selectedColorIndex)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
}


struct EditNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: NotepadViewModel
    
    var note: PetNote
    
    @State private var content: String = ""
    @State private var selectedMood: String = "sun.max.fill"
    @State private var selectedColorIndex: Int = 0
    
    let moods = ["sun.max.fill", "cloud.fill", "cloud.rain.fill", "moon.stars.fill", "heart.fill"]
    let colors: [Color] = [.orange, .blue, .red, .green, .purple]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("今天心情")) {
                    HStack {
                        ForEach(0..<moods.count, id: \.self) { index in
                            Image(systemName: moods[index])
                                .font(.title2)
                                .foregroundColor(selectedMood == moods[index] ? colors[selectedColorIndex] : .gray.opacity(0.3))
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    selectedMood = moods[index]
                                    selectedColorIndex = index
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("日记内容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("编辑日记")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    if !content.isEmpty {
                        var updatedNote = note
                        updatedNote.content = content
                        updatedNote.mood = selectedMood
                        updatedNote.moodColorIndex = selectedColorIndex
                        viewModel.updateNote(note: updatedNote)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
            .onAppear {
                content = note.content
                selectedMood = note.mood
                selectedColorIndex = note.moodColorIndex
            }
        }
    }
}

#Preview {
    NavigationView {
        NotepadView()
    }
}
