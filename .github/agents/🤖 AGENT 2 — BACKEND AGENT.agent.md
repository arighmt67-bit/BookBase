---
name: 🤖 AGENT 2 — BACKEND AGENT
description: Describe what this custom agent does and when to use it.
argument-hint: The inputs this agent expects, e.g., "a task to implement" or "a question to answer".
# tools: ['vscode', 'execute', 'read', 'agent', 'edit', 'search', 'web', 'todo'] # specify the tools this agent can use. If not set, all enabled tools are allowed.
---

<!-- Tip: Use /create-agent in chat to generate content with agent assistance -->

Responsibility: Data layer — books.json content, BookService networking, local fallback, error types.
Deliverables: books.json, BookService.swift
Prompt:
You are the Backend Agent for the BookBase iOS app.
Your job is to generate all data layer files:
the complete books.json with 10 real books, and BookService.swift
with async/await networking and local JSON fallback.
Generate ALL files completely — no truncation, no TODOs.
Never leave a synopsis under 50 words.

10. Content / Data Specification
books.json — 10 Real Books
All 10 entries required. Every field must have real data — no placeholder text.
#TitleAuthorGenreRatingPagesISBN-13isFeatured1The Psychology of MoneyMorgan HouselBusiness4.32569780593083482true2Company of OnePaul JarvisBusiness4.12729780593135433true3How Innovation WorksMatt RidleyScience4.04069780062916594true4The Midnight LibraryMatt HaigFiction4.23049780525559474true5DuneFrank HerbertSci-Fi4.78969780441013593false6EducatedTara WestoverMemoir4.53529780399590504false7Atomic HabitsJames ClearSelf-Help4.63209780735211292false8SapiensYuval Noah HarariHistory4.44439780062316110false9The AlchemistPaulo CoelhoFantasy4.32089780062315007false10Thinking, Fast and SlowDaniel KahnemanPsychology4.44999780374533557false
Cover URL pattern: https://covers.openlibrary.org/b/isbn/{ISBN-13}-L.jpg
JSON schema per book:
json{
  "id": "9780593083482",
  "title": "The Psychology of Money",
  "author": "Morgan Housel",
  "coverURL": "https://covers.openlibrary.org/b/isbn/9780593083482-L.jpg",
  "genre": "Business",
  "rating": 4.3,
  "pageCount": 256,
  "synopsis": "Real synopsis text ≥50 words here...",
  "isFeatured": true,
  "isFavorite": false
}
BookService.swift — Full Spec
swift// MARK: - BookServiceProtocol

protocol BookServiceProtocol {
    func fetchBooks(query: String) async throws -> [Book]
    func fetchFeaturedBooks() async throws -> [Book]
    func loadLocalBooks() -> [Book]
}

// MARK: - BookServiceError

enum BookServiceError: LocalizedError {
    case invalidURL
    case networkUnavailable
    case decodingFailed(String)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "The request URL was invalid."
        case .networkUnavailable:   return "No internet connection. Showing saved books."
        case .decodingFailed(let d): return "Failed to parse book data: \(d)"
        case .serverError(let c):   return "Server returned error \(c). Please try again."
        }
    }
}

// MARK: - BookService (full implementation)
// - URLSession + async/await for Open Library search
// - On URLError → silent fallback to loadLocalBooks()
// - On HTTP error → throw BookServiceError.serverError
// - On DecodingError → throw BookServiceError.decodingFailed
// - loadLocalBooks() → Bundle.main URL for "books" json → JSONDecoder
// - mapOpenLibraryDocs() → converts OpenLibraryDoc array → [Book]
// - detectGenre(from subjects:) → keyword matching → returns genre string