import SwiftUI

// MARK: - BookDetailView

struct BookDetailView: View {

    // MARK: - Properties

    let book: Book

    @Environment(HomeViewModel.self) private var viewModel
    @State private var showShareSheet = false

    private var isFavorite: Bool {
        viewModel.isFavorite(book: book)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                parallaxCover
                contentSection
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    favoriteButton
                    shareButton
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(items: [shareContent()])
        }
    }

    // MARK: - Parallax Cover

    private var parallaxCover: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let isScrolled = minY < 0

            AsyncImage(url: URL(string: book.coverURL)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                        .shimmer(isLoading: true)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .offset(y: isScrolled ? 0 : -minY * 0.4)

                case .failure:
                    ZStack {
                        Color(hex: "#EFF6FF")
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.primaryBlue.opacity(0.4))
                            Text(book.title)
                                .font(.headline)
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }

                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: geo.size.width, height: isScrolled ? 280 + minY : 280)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
        }
        .frame(height: 280)
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Title & Author
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(book.author)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
            }

            // Star Rating
            StarRatingView(rating: book.rating, starSize: 18, showNumeric: true)

            // Stats Row
            statsRow

            // Genre Tags
            genreTags

            Divider()

            // Synopsis
            synopsisSection

            Divider()

            // CTA Buttons
            ctaButtons
        }
        .padding(20)
        .background(Color.backgroundMain)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(book.pageCount)", label: "Pages")
            Divider().frame(height: 36)
            statItem(value: String(format: "%.1f", book.rating), label: "Rating")
            Divider().frame(height: 36)
            statItem(value: book.genre, label: "Genre")
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderColor, lineWidth: 1)
        )
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Genre Tags

    private var genreTags: some View {
        HStack(spacing: 8) {
            genreTag(book.genre)
            if book.isFeatured {
                genreTag("Featured")
            }
        }
    }

    private func genreTag(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.primaryBlue.opacity(0.1))
            .foregroundStyle(Color.primaryBlue)
            .clipShape(Capsule())
    }

    // MARK: - Synopsis

    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Synopsis")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text(book.synopsis)
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
        }
    }

    // MARK: - CTA Buttons

    private var ctaButtons: some View {
        VStack(spacing: 12) {
            Button {
                // Read Now — placeholder for reading functionality
            } label: {
                HStack {
                    Image(systemName: "book.fill")
                        .accessibilityHidden(true)
                    Text("Read Now")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryBlue)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Read \(book.title) now")

            Button {
                viewModel.toggleFavorite(book: book)
            } label: {
                HStack {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .accessibilityHidden(true)
                    Text(isFavorite ? "Saved to Library" : "Add to Library")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .foregroundStyle(isFavorite ? Color.red : Color.textSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isFavorite ? Color.red.opacity(0.4) : Color.borderColor, lineWidth: 1)
                )
            }
            .accessibilityLabel(isFavorite ? "Remove \(book.title) from library" : "Add \(book.title) to library")
        }
        .padding(.bottom, 12)
    }

    // MARK: - Toolbar Buttons

    private var favoriteButton: some View {
        Button {
            viewModel.toggleFavorite(book: book)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? Color.red : Color.textSecondary)
        }
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }

    private var shareButton: some View {
        Button {
            showShareSheet = true
        } label: {
            Image(systemName: "square.and.arrow.up")
                .foregroundStyle(Color.textSecondary)
        }
        .accessibilityLabel("Share \(book.title)")
    }

    // MARK: - Share Content

    private func shareContent() -> String {
        "Check out \"\(book.title)\" by \(book.author) — rated \(String(format: "%.1f", book.rating))/5 stars. Found on BookBase!"
    }
}

// MARK: - ShareSheetView

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BookDetailView(book: Book(
            id: "1",
            title: "Atomic Habits",
            author: "James Clear",
            coverURL: "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg",
            genre: "Self-Help",
            rating: 4.6,
            pageCount: 320,
            synopsis: "No matter your goals, Atomic Habits offers a proven framework for improving every day.",
            isFeatured: true
        ))
        .environment(HomeViewModel())
    }
}
