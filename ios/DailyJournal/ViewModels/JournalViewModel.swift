import Foundation
import Combine

final class JournalViewModel: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []
    @Published var searchText: String = ""
    @Published var selectedMood: Mood?
    @Published var errorMessage: String?

    private let storage: JournalStorage

    init(storage: JournalStorage = FileJournalStorage()) {
        self.storage = storage
        loadEntries()
    }

    func loadEntries() {
        do {
            entries = try storage.loadEntries().sorted { $0.date > $1.date }
        } catch {
            errorMessage = "无法读取本地记录：\(error.localizedDescription)"
            entries = [JournalEntry.placeholder]
        }
    }

    func displayedEntries() -> [JournalEntry] {
        var filtered = entries

        if !searchText.isEmpty {
            filtered = filtered.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.body.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        if let selectedMood {
            filtered = filtered.filter { $0.mood == selectedMood }
        }

        return filtered.sorted { $0.date > $1.date }
    }

    func createEntry(from draft: EntryDraft) {
        var newEntry = draft.toEntry()
        newEntry.id = UUID()
        entries.insert(newEntry, at: 0)
        persist()
    }

    func updateEntry(_ entry: JournalEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index] = entry
        persist()
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        persist()
    }

    func resetFilters() {
        searchText = ""
        selectedMood = nil
    }

    private func persist() {
        do {
            try storage.saveEntries(entries)
        } catch {
            errorMessage = "保存失败：\(error.localizedDescription)"
        }
    }
}

struct EntryDraft {
    var id: UUID?
    var title: String
    var body: String
    var date: Date
    var mood: Mood
    var tags: [String]

    init(id: UUID? = nil, title: String = "", body: String = "", date: Date = Date(), mood: Mood = .neutral, tags: [String] = []) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.mood = mood
        self.tags = tags
    }

    init(entry: JournalEntry) {
        self.init(id: entry.id, title: entry.title, body: entry.body, date: entry.date, mood: entry.mood, tags: entry.tags)
    }

    func toEntry() -> JournalEntry {
        JournalEntry(id: id ?? UUID(), date: date, title: title, body: body, mood: mood, tags: tags)
    }
}
