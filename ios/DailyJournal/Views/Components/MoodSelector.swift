import SwiftUI

struct MoodSelector: View {
    @Binding var selectedMood: Mood

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.title)
                            Text(mood.title)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(minWidth: 72)
                        .background(selectedMood == mood ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
