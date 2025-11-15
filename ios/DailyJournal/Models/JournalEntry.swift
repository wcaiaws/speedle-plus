import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var title: String
    var body: String
    var mood: Mood
    var tags: [String]

    init(id: UUID = UUID(), date: Date = Date(), title: String, body: String, mood: Mood = .neutral, tags: [String] = []) {
        self.id = id
        self.date = date
        self.title = title
        self.body = body
        self.mood = mood
        self.tags = tags
    }
}

extension JournalEntry {
    static let placeholder = JournalEntry(
        date: Date(),
        title: "今天发生了什么？",
        body: "写下让你印象深刻的瞬间，或是一段心情……",
        mood: .peaceful,
        tags: ["灵感"]
    )
}
