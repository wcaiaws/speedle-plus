import SwiftUI

struct JournalDetailView: View {
    let entry: JournalEntry
    var onEdit: (() -> Void)?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 48))
                    VStack(alignment: .leading) {
                        Text(entry.title)
                            .font(.title2)
                            .bold()
                        Text(dateFormatter.string(from: entry.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                if !entry.tags.isEmpty {
                    WrapTagView(tags: entry.tags)
                }

                Text(entry.body)
                    .font(.body)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle("详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onEdit {
                Button("编辑", action: onEdit)
            }
        }
    }
}

private struct WrapTagView: View {
    let tags: [String]
    private let columns = [GridItem(.adaptive(minimum: 90), alignment: .leading)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text("#" + tag)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
}
