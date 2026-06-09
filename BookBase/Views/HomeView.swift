import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    // MARK: - Properties

    @Environment(HomeViewModel.self) private var viewModel

    // MARK: - Body

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            ZStack(alignment: .top) {
                Color.backgroundMain.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if viewModel.isOfflineMode {
                            HStack {
                                Spacer()
                                OfflineBannerView()
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }

                        // MARK: Search Bar
                        searchBar

                        // MARK: Category Chips
                        categoryChips

                        // MARK: Featured Section
                        if !viewModel.featuredBooks.isEmpty {
                            featuredSection
                        }

                        // MARK: Recommended Shelf
                        recommendedSection

                        Spacer(minLength: 24)
                    }
                }
                .refreshable {
                    await viewModel.loadBooks()
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .alert("Something went wrong", isPresented: Binding(
                get: { viewModel.showError },
                set: { viewModel.showError = $0 }
            )) {
                Button("Retry") {
                    Task { await viewModel.retry() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .task {
                if viewModel.books.isEmpty {
                    await viewModel.loadBooks()
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        @Bindable var vm = viewModel

        return HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textSecondary)
                .accessibilityHidden(true)

            TextField("Search books or authors...", text: $vm.searchText)
                .font(.body)
                .accessibilityLabel("Search books by title or author")
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        if !viewModel.searchText.isEmpty {
                            await viewModel.search(query: viewModel.searchText)
                        }
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textSecondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppConstants.genres, id: \.self) { genre in
                    GenreChipView(
                        genre: genre,
                        isSelected: viewModel.selectedGenre == genre
                    ) {
                        viewModel.selectedGenre = genre
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .background(Color.categoriesBg)
        .padding(.bottom, 8)
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredBooks) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            FeaturedCardView(book: book)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    // MARK: - Recommended Section

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.searchText.isEmpty && viewModel.selectedGenre == "All" ? "Recommended" : "Results")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Text("\(viewModel.filteredBooks.count) books")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, 16)

            switch viewModel.loadingState {
            case .loading:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<6, id: \.self) { _ in
                            BookCardSkeleton()
                        }
                    }
                    .padding(.horizontal, 16)
                }

            case .success, .idle:
                if viewModel.filteredBooks.isEmpty {
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "No books found",
                        subtitle: "Try a different search term or category.",
                        actionTitle: "Clear filters"
                    ) {
                        viewModel.searchText = ""
                        viewModel.selectedGenre = "All"
                    }
                    .frame(height: 220)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.filteredBooks) { book in
                                NavigationLink(destination: BookDetailView(book: book)) {
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                    }
                }

            case .error(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.orange)
                        .accessibilityHidden(true)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button("Retry") {
                        Task { await viewModel.retry() }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Retry loading books")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
        .background(Color.recommendedBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 8)
    }
}

// MARK: - FeaturedCardView

struct FeaturedCardView: View {

    let book: Book

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: book.coverURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    Color.gray.opacity(0.2).shimmer(isLoading: true)
                case .failure:
                    Color(hex: "#1E3A5F")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 260, height: 160)
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.7), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)

                Text(book.author)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.85))

                StarRatingView(rating: book.rating, starSize: 12, showNumeric: true)
            }
            .padding(12)
        }
        .frame(width: 260, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Featured: \(book.title) by \(book.author)")
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environment(HomeViewModel())
}
