import SwiftUI

// MARK: - BookBaseApp

@main
struct BookBaseApp: App {
    @State private var viewModel = HomeViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
