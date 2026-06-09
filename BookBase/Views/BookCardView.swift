import SwiftUI

// MARK: - BookCardView

struct BookCardView: View {

    // MARK: - Properties

    let book: Book

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            coverImage
            bookInfo
        }
        .frame(width: AppConstants.cardWidth)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(book.title) by \(book.author), rated \(String(format: "%.1f", book.rating)) stars")
    }

    // MARK: - Cover Image

    private var coverImage: some View {
        AsyncImage(url: URL(string: book.coverURL)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.12))
                    .shimmer(isLoading: true)
                    .frame(width: AppConstants.cardWidth, height: AppConstants.cardCoverHeight)

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: AppConstants.cardWidth, height: AppConstants.cardCoverHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))

            case .failure:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#EFF6FF"))
                    .frame(width: AppConstants.cardWidth, height: AppConstants.cardCoverHeight)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.primaryBlue.opacity(0.5))
                            Text(book.title)
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                    }

            @unknown default:
                EmptyView()
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    // MARK: - Book Info

    private var bookInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(book.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(2)
                .frame(width: AppConstants.cardWidth, alignment: .leading)

            Text(book.author)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)

            StarRatingView(rating: book.rating, starSize: 11, showNumeric: false)
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        BookCardView(book: Book(
            id: "1",
            title: "Atomic Habits",
            author: "James Clear",
            coverURL: "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg",
            genre: "Self-Help",
            rating: 4.6,
            pageCount: 320,
            synopsis: "A great book.",
            isFeatured: true
        ))
    }
    .padding()
}
