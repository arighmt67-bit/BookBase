import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    // MARK: - State

    @State private var selectedTab: Int = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Discover", systemImage: "house.fill")
                }
                .tag(0)

            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "books.vertical.fill")
                }
                .tag(1)

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "heart.fill")
                }
                .tag(2)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .tint(Color.primaryBlue)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
