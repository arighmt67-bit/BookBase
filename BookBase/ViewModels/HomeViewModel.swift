import SwiftUI
import Observation

// MARK: - HomeViewModel

@Observable
final class HomeViewModel {

    // MARK: - Published State

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

    var featuredBooks: [Book] {
        books.filter { $0.isFeatured }
    }

    var recommendedBooks: [Book] {
        Array(books.prefix(10))
    }

    var favoriteBooks: [Book] {
        books.filter { $0.isFavorite }
    }

    // MARK: - Init

    init(bookService: BookServiceProtocol = BookService()) {
        self.bookService = bookService
        loadFavorites()
    }

    // MARK: - Load Books

    @MainActor
    func loadBooks() async {
        loadingState = .loading

        do {
            let fetched = try await bookService.fetchBooks(query: "")
            var merged = fetched.isEmpty ? bookService.loadLocalBooks() : fetched
            isOfflineMode = fetched.isEmpty

            // Re-apply saved favorites
            let savedFavorites = loadSavedFavoriteIDs()
            for i in merged.indices {
                merged[i].isFavorite = savedFavorites.contains(merged[i].id)
            }

            books = merged
            loadingState = .success(merged)
        } catch {
            let localBooks = bookService.loadLocalBooks()
            if !localBooks.isEmpty {
                var merged = localBooks
                applyPersistedFavorites(to: &merged)
                books = merged
                isOfflineMode = true
                loadingState = .success(merged)
            } else {
                errorMessage = error.localizedDescription
                showError = true
                loadingState = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Search

    @MainActor
    func search(query: String) async {
        guard !query.isEmpty else { return }
        loadingState = .loading

        do {
            let results = try await bookService.fetchBooks(query: query)
            if results.isEmpty {
                var localBooks = bookService.loadLocalBooks()
                applyPersistedFavorites(to: &localBooks)
                books = localBooks
            } else {
                books = results
            }
            loadingState = .success(books)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            loadingState = .error(error.localizedDescription)
        }
    }

    // MARK: - Favorites

    func toggleFavorite(book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].isFavorite.toggle()
        saveFavorites()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func isFavorite(book: Book) -> Bool {
        books.first(where: { $0.id == book.id })?.isFavorite ?? false
    }

    // MARK: - Persistence

    private func saveFavorites() {
        let ids = books.filter { $0.isFavorite }.map { $0.id }
        UserDefaults.standard.set(ids, forKey: StorageKeys.favoriteBookIDs)
    }

    private func loadFavorites() {
        let savedFavorites = loadSavedFavoriteIDs()
        for i in books.indices {
            books[i].isFavorite = savedFavorites.contains(books[i].id)
        }
    }

    private func loadSavedFavoriteIDs() -> Set<String> {
        let ids = UserDefaults.standard.stringArray(forKey: StorageKeys.favoriteBookIDs) ?? []
        return Set(ids)
    }

    private func applyPersistedFavorites(to books: inout [Book]) {
        let savedFavorites = loadSavedFavoriteIDs()
        for index in books.indices {
            books[index].isFavorite = savedFavorites.contains(books[index].id)
        }
    }

    // MARK: - Retry

    @MainActor
    func retry() async {
        showError = false
        await loadBooks()
    }
}
