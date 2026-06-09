---
name: AGENT 1 — STRUCTURE AGENT
description: Describe what this custom agent does and when to use it.
argument-hint: The inputs this agent expects, e.g., "a task to implement" or "a question to answer".
# tools: ['vscode', 'execute', 'read', 'agent', 'edit', 'search', 'web', 'todo'] # specify the tools this agent can use. If not set, all enabled tools are allowed.
---

<!-- Tip: Use /create-agent in chat to generate content with agent assistance -->

Responsibility: Project scaffolding, folder structure, data models, constants, app entry point, and ViewModel.
Deliverables: BookBaseApp.swift, Constants.swift, Book.swift, HomeViewModel.swift
Prompt:
You are the Structure Agent for the BookBase iOS app.
Your job is to generate the project foundation files:
folder structure, data models, constants, ViewModel, and app entry point.
Generate ALL files completely — no truncation, no TODOs.

4. App Structure
BookBase/
├── BookBaseApp.swift               ← @main entry point
├── Models/
│   └── Book.swift                  ← Book struct + LoadingState<T> enum + OpenLibrary response models
├── ViewModels/
│   └── HomeViewModel.swift         ← @Observable, search, filter, favorites, persistence, error handling
├── Views/
│   ├── ContentView.swift           ← TabView root (ONLY here — delete Xcode's auto-generated root ContentView.swift)
│   ├── HomeView.swift              ← Tab 1: Discover screen
│   ├── BrowseView.swift            ← Tab 2: Browse list screen
│   ├── LibraryView.swift           ← Tab 3: My Library favorites grid
│   ├── AboutView.swift             ← Tab 4: Developer profile
│   ├── BookDetailView.swift        ← Pushed detail screen (satisfies Dicoding "halaman detail")
│   ├── BookCardView.swift          ← Reusable 140×200pt shelf card
│   ├── StarRatingView.swift        ← Half-star SF Symbol component
│   ├── ShimmerView.swift           ← Skeleton loading + BookCardSkeleton
│   └── SupportingViews.swift       ← GenreChipView, EmptyStateView, OfflineBannerView, BookRowView, FeaturedCardView, ShareSheetView
├── Services/
│   └── BookService.swift           ← URLSession async/await + local JSON fallback
├── Utilities/
│   └── Constants.swift             ← Color(hex:) extension + AppConstants enum
└── Resources/
    └── books.json                  ← 10 real books, bundled — must be added to Xcode target

⚠️ Critical Xcode note — Structure Agent must document this: When Xcode creates a new project, it auto-generates BookBase/ContentView.swift at the project root. The generated Views/ContentView.swift is a different file. Having both causes fatal build error: "Filename ContentView.swift used twice." — Delete the root-level ContentView.swift immediately after project creation.


5. Data Models
swift// MARK: - Book.swift

import Foundation

// MARK: - Book Model

struct Book: Identifiable, Codable, Hashable {
    let id: String           // ISBN-13 string — stable identifier
    let title: String
    let author: String
    let coverURL: String     // https://covers.openlibrary.org/b/isbn/{ISBN}-L.jpg
    let genre: String        // One of: Business|Science|Fiction|Sci-Fi|Memoir|Self-Help|History|Fantasy|Psychology
    let rating: Double       // 0.0–5.0, real Goodreads rating
    let pageCount: Int
    let synopsis: String     // Real description ≥50 words
    let isFeatured: Bool     // true for books 1–4 — shown in Featured shelf
    var isFavorite: Bool = false  // toggled by user, persisted via UserDefaults

    enum CodingKeys: String, CodingKey {
        case id, title, author, coverURL, genre, rating,
             pageCount, synopsis, isFeatured, isFavorite
    }
}

// MARK: - Loading State

enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
}

// MARK: - Open Library API Response Models

struct OpenLibraryResponse: Codable {
    let docs: [OpenLibraryDoc]
    let numFound: Int
}

struct OpenLibraryDoc: Codable {
    let key: String?
    let title: String?
    let authorName: [String]?
    let isbn: [String]?
    let numberOfPagesMedian: Int?
    let subject: [String]?

    enum CodingKeys: String, CodingKey {
        case key, title
        case authorName          = "author_name"
        case isbn
        case numberOfPagesMedian = "number_of_pages_median"
        case subject
    }
}
swift// MARK: - Constants.swift

import SwiftUI

// MARK: - Color Extension

extension Color {
    static let primaryBlue    = Color(hex: "#2563EB")
    static let primaryDark    = Color(hex: "#1D4ED8")
    static let backgroundMain = Color(hex: "#F8FAFC")
    static let surface        = Color.white
    static let textPrimary    = Color(hex: "#0F172A")
    static let textSecondary  = Color(hex: "#64748B")
    static let borderColor    = Color(hex: "#E2E8F0")
    static let starAmber      = Color(hex: "#F59E0B")
    static let recommendedBg  = Color(hex: "#EFF6FF")
    static let categoriesBg   = Color(hex: "#F0FDF4")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - App Constants

enum AppConstants {
    static let openLibrarySearchURL = "https://openlibrary.org/search.json"
    static let openLibraryCoverBase = "https://covers.openlibrary.org/b/isbn"
    static let genres = ["All","Business","Science","Fiction","Sci-Fi",
                         "Memoir","Self-Help","History","Fantasy","Psychology"]
    static let cardWidth: CGFloat        = 140
    static let cardCoverHeight: CGFloat  = 200
    static let gridColumns               = 2
}

// MARK: - Storage Keys

enum StorageKeys {
    static let favoriteBookIDs = "favoriteBookIDs"  // [String]
}
swift// MARK: - HomeViewModel.swift

import SwiftUI
import Observation

@Observable
final class HomeViewModel {

    // MARK: - State

    var books: [Book] = []
    var loadingState: LoadingState<[Book]> = .idle
    var searchText: String = ""
    var selectedGenre: String = "All"
    var isOfflineMode: Bool = false
    var errorMessage: String = ""
    var showError: Bool = false

    // MARK: - Dependencies

    private let bookService: BookServiceProtocol

    // MARK: - Computed Properties

    var filteredBooks: [Book] {
        var result = books
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
        if selectedGenre != "All" {
            result = result.filter { $0.genre == selectedGenre }
        }
        return result
    }

    var featuredBooks: [Book]  { books.filter { $0.isFeatured } }
    var favoriteBooks: [Book]  { books.filter { $0.isFavorite } }
    var recommendedBooks: [Book] { Array(books.prefix(10)) }

    // MARK: - Init

    init(bookService: BookServiceProtocol = BookService()) {
        self.bookService = bookService
    }

    // MARK: - Load

    @MainActor
    func loadBooks() async {
        loadingState = .loading
        do {
            var fetched = try await bookService.fetchBooks(query: "")
            isOfflineMode = fetched.isEmpty
            if fetched.isEmpty { fetched = bookService.loadLocalBooks() }
            applyPersistedFavorites(to: &fetched)
            books = fetched
            loadingState = .success(fetched)
        } catch {
            let local = bookService.loadLocalBooks()
            if !local.isEmpty {
                var localBooks = local
                applyPersistedFavorites(to: &localBooks)
                books = localBooks
                isOfflineMode = true
                loadingState = .success(localBooks)
            } else {
                errorMessage = error.localizedDescription
                showError = true
                loadingState = .error(error.localizedDescription)
            }
        }
    }

    @MainActor
    func search(query: String) async {
        guard !query.isEmpty else { return }
        loadingState = .loading
        do {
            let results = try await bookService.fetchBooks(query: query)
            books = results.isEmpty ? bookService.loadLocalBooks() : results
            loadingState = .success(books)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            loadingState = .error(error.localizedDescription)
        }
    }

    @MainActor
    func retry() async { showError = false; await loadBooks() }

    // MARK: - Favorites

    func toggleFavorite(book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].isFavorite.toggle()
        persistFavorites()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func isFavorite(book: Book) -> Bool {
        books.first(where: { $0.id == book.id })?.isFavorite ?? false
    }

    // MARK: - Persistence

    private func persistFavorites() {
        let ids = books.filter { $0.isFavorite }.map { $0.id }
        UserDefaults.standard.set(ids, forKey: StorageKeys.favoriteBookIDs)
    }

    private func applyPersistedFavorites(to books: inout [Book]) {
        let savedIDs = Set(UserDefaults.standard.stringArray(
                           forKey: StorageKeys.favoriteBookIDs) ?? [])
        for i in books.indices {
            books[i].isFavorite = savedIDs.contains(books[i].id)
        }
    }
}
swift// MARK: - BookBaseApp.swift

import SwiftUI

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
