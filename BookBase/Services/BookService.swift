import Foundation

// MARK: - BookService Protocol

protocol BookServiceProtocol {
    func fetchBooks(query: String) async throws -> [Book]
    func fetchFeaturedBooks() async throws -> [Book]
    func loadLocalBooks() -> [Book]
}

// MARK: - BookService Errors

enum BookServiceError: LocalizedError {
    case invalidURL
    case networkUnavailable
    case decodingFailed(String)
    case serverError(Int)
    case localDataMissing

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .networkUnavailable:
            return "No internet connection. Showing saved books."
        case .decodingFailed(let detail):
            return "Failed to parse book data: \(detail)"
        case .serverError(let code):
            return "Server returned error \(code). Please try again."
        case .localDataMissing:
            return "Could not find local book data."
        }
    }
}

// MARK: - BookService

final class BookService: BookServiceProtocol {

    // MARK: - Properties

    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Init

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Fetch Books (Open Library)

    func fetchBooks(query: String) async throws -> [Book] {
        guard !query.isEmpty else {
            return loadLocalBooks()
        }

        guard var components = URLComponents(string: AppConstants.openLibrarySearchURL) else {
            throw BookServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "fields", value: "key,title,author_name,isbn,number_of_pages_median,subject"),
            URLQueryItem(name: "limit", value: "20")
        ]

        guard let url = components.url else {
            throw BookServiceError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                throw BookServiceError.serverError(httpResponse.statusCode)
            }

            let libraryResponse = try decoder.decode(OpenLibraryResponse.self, from: data)
            return mapOpenLibraryDocs(libraryResponse.docs)

        } catch is URLError {
            return loadLocalBooks()
        } catch let error as BookServiceError {
            throw error
        } catch {
            throw BookServiceError.decodingFailed(error.localizedDescription)
        }
    }

    // MARK: - Fetch Featured Books

    func fetchFeaturedBooks() async throws -> [Book] {
        return loadLocalBooks().filter { $0.isFeatured }
    }

    // MARK: - Load Local Books

    func loadLocalBooks() -> [Book] {
        guard let url = Bundle.main.url(forResource: "books", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let books = try? decoder.decode([Book].self, from: data) else {
            return []
        }
        return books
    }

    // MARK: - Map Open Library to Book Model

    private func mapOpenLibraryDocs(_ docs: [OpenLibraryDoc]) -> [Book] {
        return docs.compactMap { doc in
            guard let title = doc.title,
                  let isbn = doc.isbn?.first else { return nil }

            let author = doc.authorName?.first ?? "Unknown Author"
            let coverURL = "\(AppConstants.openLibraryCoverURL)/\(isbn)-L.jpg"
            let genre = detectGenre(from: doc.subject ?? [])
            let pages = doc.numberOfPagesMedian ?? 300

            return Book(
                id: isbn,
                title: title,
                author: author,
                coverURL: coverURL,
                genre: genre,
                rating: 4.0,
                pageCount: pages,
                synopsis: "Discover more about \(title) by \(author). A captivating read that explores profound ideas and invites readers on an unforgettable journey.",
                isFeatured: false,
                isFavorite: false
            )
        }
    }

    // MARK: - Genre Detection

    private func detectGenre(from subjects: [String]) -> String {
        let lowered = subjects.map { $0.lowercased() }
        if lowered.contains(where: { $0.contains("science fiction") || $0.contains("sci-fi") }) { return "Sci-Fi" }
        if lowered.contains(where: { $0.contains("fantasy") }) { return "Fantasy" }
        if lowered.contains(where: { $0.contains("business") || $0.contains("economics") }) { return "Business" }
        if lowered.contains(where: { $0.contains("biography") || $0.contains("memoir") }) { return "Memoir" }
        if lowered.contains(where: { $0.contains("psychology") }) { return "Psychology" }
        if lowered.contains(where: { $0.contains("history") }) { return "History" }
        if lowered.contains(where: { $0.contains("self-help") || $0.contains("self help") }) { return "Self-Help" }
        if lowered.contains(where: { $0.contains("science") }) { return "Science" }
        return "Fiction"
    }
}
