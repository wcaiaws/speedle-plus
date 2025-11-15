import SwiftUI

struct EntryCard: View {
    let entry: JournalEntry
    private let dateFormatter: DateFormatter

    init(entry: JournalEntry) {
        self.entry = entry
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        self.dateFormatter = formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.headline)
                    Text(dateFormatter.string(from: entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(entry.mood.emoji)
                    .font(.largeTitle)
            }
            Text(entry.body)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.primary)
            if !entry.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(entry.tags.prefix(3), id: \.self) { tag in
                        Text("#" + tag)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 12)
    }
}
