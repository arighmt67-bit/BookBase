import SwiftUI

// MARK: - BrowseView

struct BrowseView: View {

    // MARK: - Properties

    @Environment(HomeViewModel.self) private var viewModel
    @State private var selectedGenre: String = "All"

    private var filteredBooks: [Book] {
        if selectedGenre == "All" {
            return viewModel.books
        }
        return viewModel.books.filter { $0.genre == selectedGenre }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                genreFilter
                bookList
            }
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.backgroundMain)
        }
    }

    // MARK: - Genre Filter

    private var genreFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppConstants.genres, id: \.self) { genre in
                    GenreChipView(
                        genre: genre,
                        isSelected: selectedGenre == genre
                    ) {
                        selectedGenre = genre
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Book List

    @ViewBuilder
    private var bookList: some View {
        if viewModel.books.isEmpty {
            ProgressView("Loading books...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredBooks.isEmpty {
            EmptyStateView(
                systemImage: "books.vertical",
                title: "No books in this category",
                subtitle: "Try selecting a different genre.",
                actionTitle: "Show all",
                action: { selectedGenre = "All" }
            )
        } else {
            List {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookRowView(book: book)
                    }
                    .listRowBackground(Color.backgroundMain)
                    .listRowSeparatorTint(Color.borderColor)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            viewModel.toggleFavorite(book: book)
                        } label: {
                            Label(
                                viewModel.isFavorite(book: book) ? "Unfavorite" : "Favorite",
                                systemImage: viewModel.isFavorite(book: book) ? "heart.slash.fill" : "heart.fill"
                            )
                        }
                        .tint(viewModel.isFavorite(book: book) ? .gray : .red)
                        .accessibilityLabel(viewModel.isFavorite(book: book) ? "Remove from favorites" : "Add to favorites")
                    }
                }
            }
            .listStyle(.plain)
            .background(Color.backgroundMain)
        }
    }
}

// MARK: - BookRowView

struct BookRowView: View {

    let book: Book

    var body: some View {
        HStack(spacing: 12) {
            // Cover thumbnail
            AsyncImage(url: URL(string: book.coverURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    Color.gray.opacity(0.15).shimmer(isLoading: true)
                case .failure:
                    ZStack {
                        Color(hex: "#EFF6FF")
                        Image(systemName: "book.closed")
                            .foregroundStyle(Color.primaryBlue.opacity(0.5))
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 56, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                Text(book.author)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                HStack(spacing: 6) {
                    genreBadge(book.genre)
                    StarRatingView(rating: book.rating, starSize: 12, showNumeric: true)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(book.title) by \(book.author), \(book.genre), rated \(String(format: "%.1f", book.rating)) stars")
    }

    private func genreBadge(_ genre: String) -> some View {
        Text(genre)
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.primaryBlue.opacity(0.1))
            .foregroundStyle(Color.primaryBlue)
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    BrowseView()
        .environment(HomeViewModel())
}
