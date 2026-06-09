import SwiftUI

// MARK: - LibraryView

struct LibraryView: View {

    // MARK: - Properties

    @Environment(HomeViewModel.self) private var viewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favoriteBooks.isEmpty {
                    emptyState
                } else {
                    favoriteGrid
                }
            }
            .navigationTitle("My Library")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.backgroundMain)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "heart.slash",
            title: "No books saved yet",
            subtitle: "Tap the heart on any book to save it here for easy access.",
            actionTitle: "Browse Books",
            action: {
                // Handled by TabView parent — this tab switch would require a tab selection binding
            }
        )
    }

    // MARK: - Favorites Grid

    private var favoriteGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(viewModel.favoriteBooks.count) saved book\(viewModel.favoriteBooks.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .accessibilityLabel("\(viewModel.favoriteBooks.count) saved books")

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.favoriteBooks) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            libraryBookCard(book: book)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Library Book Card

    private func libraryBookCard(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
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
                            VStack(spacing: 8) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.primaryBlue.opacity(0.4))
                                Text(book.title)
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 6)
                            }
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Heart badge
                Button {
                    viewModel.toggleFavorite(book: book)
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.red)
                        .padding(8)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(8)
                .accessibilityLabel("Remove \(book.title) from library")
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(book.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                Text(book.author)
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(book.title) by \(book.author), saved to library")
    }
}

// MARK: - Preview

#Preview {
    LibraryView()
        .environment(HomeViewModel())
}
