import SwiftUI

@main
struct DailyJournalApp: App {
    @StateObject private var viewModel = JournalViewModel()

    var body: some Scene {
        WindowGroup {
            JournalListView(viewModel: viewModel)
        }
    }
}
