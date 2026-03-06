import SwiftUI
import Foundation
import Combine

struct PetNote: Identifiable, Codable {
    var id = UUID()
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
    @Published var notes: [PetNote] = [] {
        didSet {
            saveNotes()
        }
    }
    
    init() {
        loadNotes()
        if notes.isEmpty {
            // Mock data
            notes = [
                PetNote(date: Date().addingTimeInterval(-86400*2), mood: "sun.max.fill", moodColorIndex: 0, content: "今天给布丁洗了澡，它非常乖，没有闹腾！奖励了一个大罐头。🥩"),
                PetNote(date: Date().addingTimeInterval(-86400*6), mood: "cloud.rain.fill", moodColorIndex: 1, content: "下雨天，布丁一整天都在睡懒觉，发现它有一点挑食，明天开始尝试换一下猫粮的牌子。"),
                PetNote(date: Date().addingTimeInterval(-86400*11), mood: "heart.fill", moodColorIndex: 2, content: "带去打了今年的狂犬疫苗，体重涨了0.5kg，医生说是个健康的胖小子！")
            ]
        }
    }
    
    private let notesKey = "saved_pet_notes"
    
    func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([PetNote].self, from: data) {
            notes = decoded
        }
    }
    
    func addNote(content: String, mood: String, moodColorIndex: Int) {
        let newNote = PetNote(date: Date(), mood: mood, moodColorIndex: moodColorIndex, content: content)
        notes.insert(newNote, at: 0) // prepend
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

struct NotepadView: View {
    @StateObject private var viewModel = NotepadViewModel()
    @State private var showingAddSheet = false

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
                            DiaryCard(note: note) {
                                // delete action
                                if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                                    withAnimation {
                                        viewModel.notes.remove(at: index)
                                        viewModel.saveNotes()
                                    }
                                }
                            }
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
    }
}

// 日记卡片子组件
struct DiaryCard: View {
    let note: PetNote
    let onDelete: () -> Void
    
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
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.6))
                        .padding(.leading, 10)
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

#Preview {
    NavigationView {
        NotepadView()
    }
}
