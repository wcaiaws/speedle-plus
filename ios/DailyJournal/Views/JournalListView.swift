import SwiftUI

struct JournalListView: View {
    @ObservedObject var viewModel: JournalViewModel
    @State private var isPresentingEditor = false
    @State private var draft = EntryDraft()
    @State private var editorMode: EditorMode = .create

    enum EditorMode {
        case create
        case update(JournalEntry)

        var title: String {
            switch self {
            case .create: return "新建日记"
            case .update: return "编辑日记"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.displayedEntries().isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("日常记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.selectedMood != nil || !viewModel.searchText.isEmpty {
                        Button("重置") { viewModel.resetFilters() }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: presentCreate) {
                        Label("添加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                EntryEditorView(draft: draft, title: editorMode.title) { newDraft in
                    switch editorMode {
                    case .create:
                        viewModel.createEntry(from: newDraft)
                    case .update:
                        viewModel.updateEntry(newDraft.toEntry())
                    }
                    isPresentingEditor = false
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索标题、内容或标签")
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert("提示", isPresented: errorAlertBinding) {
            Button("好的", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
    }

    private var list: some View {
        List {
            moodFilterSection
            ForEach(viewModel.displayedEntries()) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry, onEdit: {
                    presentUpdate(for: entry)
                })) {
                    EntryCard(entry: entry)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.deleteEntry(entry)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
                .contextMenu {
                    Button("编辑") { presentUpdate(for: entry) }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var moodFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button {
                    viewModel.selectedMood = nil
                } label: {
                    FilterChip(title: "全部", isSelected: viewModel.selectedMood == nil)
                }
                ForEach(Mood.allCases) { mood in
                    Button {
                        viewModel.selectedMood = mood
                    } label: {
                        FilterChip(title: mood.title, subtitle: mood.emoji, isSelected: viewModel.selectedMood == mood)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text("还没有记录")
                .font(.title3)
                .bold()
            Text("点击右上角的“+”开始记录你的日常灵感或情绪。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Button(action: presentCreate) {
                Label("开始记录", systemImage: "plus")
                    .padding(.horizontal, 24)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func presentCreate() {
        draft = EntryDraft()
        editorMode = .create
        isPresentingEditor = true
    }

    private func presentUpdate(for entry: JournalEntry) {
        draft = EntryDraft(entry: entry)
        editorMode = .update(entry)
        isPresentingEditor = true
    }
}

private struct FilterChip: View {
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            if let subtitle {
                Text(subtitle)
            }
            Text(title)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
        .foregroundColor(isSelected ? .accentColor : .primary)
        .clipShape(Capsule())
    }
}

private extension JournalListView {
    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { show in
                if !show {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}
