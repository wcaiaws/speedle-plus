import SwiftUI

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: EntryDraft

    let title: String
    let onSave: (EntryDraft) -> Void

    init(draft: EntryDraft, title: String, onSave: @escaping (EntryDraft) -> Void) {
        _draft = State(initialValue: draft)
        self.title = title
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("标题") {
                    TextField("今天的标题", text: $draft.title)
                }
                Section("正文") {
                    TextEditor(text: $draft.body)
                        .frame(minHeight: 160)
                }
                Section("时间") {
                    DatePicker("记录时间", selection: $draft.date, displayedComponents: [.date, .hourAndMinute])
                }
                Section("情绪") {
                    MoodSelector(selectedMood: $draft.mood)
                }
                Section("标签") {
                    TagEditor(tags: $draft.tags)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var canSave: Bool {
        !draft.title.trimmingCharacters(in: .whitespaces).isEmpty && !draft.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        onSave(draft)
        dismiss()
    }
}

private struct TagEditor: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 8, alignment: .leading)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("添加标签", text: $newTag)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)
                Button("添加") {
                    appendTag()
                }
                .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text("#" + tag)
                            .font(.caption)
                        Button(role: .destructive) {
                            tags.removeAll { $0 == tag }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
    }

    private func appendTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !tags.contains(trimmed) {
            tags.append(trimmed)
        }
        newTag = ""
    }
}
