import SwiftUI

// MARK: - App Colors

extension Color {
    static let primaryBlue = Color(hex: "#2563EB")
    static let backgroundMain = Color(hex: "#F8FAFC")
    static let surface = Color.white
    static let textPrimary = Color(hex: "#0F172A")
    static let textSecondary = Color(hex: "#64748B")
    static let borderColor = Color(hex: "#E2E8F0")
    static let recommendedBg = Color(hex: "#EFF6FF")
    static let categoriesBg = Color(hex: "#F0FDF4")
    static let featuredBg = Color(hex: "#1E3A5F")
    static let starAmber = Color(hex: "#F59E0B")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Constants

enum AppConstants {
    static let openLibrarySearchURL = "https://openlibrary.org/search.json"
    static let openLibraryCoverURL = "https://covers.openlibrary.org/b/isbn"
    static let genres = ["All", "Business", "Science", "Fiction", "Sci-Fi", "Memoir", "Self-Help", "History", "Fantasy", "Psychology"]
    static let cardWidth: CGFloat = 140
    static let cardCoverHeight: CGFloat = 200
    static let gridColumns = 2
}

// MARK: - Storage Keys

enum StorageKeys {
    static let favoriteBookIDs = "favoriteBookIDs"
}
