import Foundation

// MARK: - Book Model

struct Book: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let author: String
    let coverURL: String
    let genre: String
    let rating: Double
    let pageCount: Int
    let synopsis: String
    let isFeatured: Bool
    var isFavorite: Bool = false

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id, title, author, coverURL, genre, rating, pageCount, synopsis, isFeatured, isFavorite
    }
}

// MARK: - Loading State

enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
}

// MARK: - Books Response (for Open Library)

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
        case authorName = "author_name"
        case isbn
        case numberOfPagesMedian = "number_of_pages_median"
        case subject
    }
}
