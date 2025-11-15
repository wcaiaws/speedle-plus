import Foundation

protocol JournalStorage: AnyObject {
    func loadEntries() throws -> [JournalEntry]
    func saveEntries(_ entries: [JournalEntry]) throws
}

final class FileJournalStorage: JournalStorage {
    private let fileURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(fileName: String = "journal_entries.json") {
        #if os(iOS)
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        #else
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
        #endif
        self.fileURL = directory.appendingPathComponent(fileName)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder
    }

    func loadEntries() throws -> [JournalEntry] {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([JournalEntry].self, from: data)
        }
        return try loadSeedEntries()
    }

    func saveEntries(_ entries: [JournalEntry]) throws {
        let data = try encoder.encode(entries.sorted { $0.date > $1.date })
        try data.write(to: fileURL, options: [.atomic])
    }

    private func loadSeedEntries() throws -> [JournalEntry] {
        guard let url = Bundle.main.url(forResource: "seed", withExtension: "json", subdirectory: "MockData") ?? Bundle.main.url(forResource: "seed", withExtension: "json") else {
            return [JournalEntry.placeholder]
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode([JournalEntry].self, from: data)
    }
}

final class InMemoryJournalStorage: JournalStorage {
    private var entries: [JournalEntry]

    init(entries: [JournalEntry] = [JournalEntry.placeholder]) {
        self.entries = entries
    }

    func loadEntries() throws -> [JournalEntry] {
        entries
    }

    func saveEntries(_ entries: [JournalEntry]) throws {
        self.entries = entries
    }
}
