---
name: 🤖 AGENT 3 — UI AGENT
description: Describe what this custom agent does and when to use it.
argument-hint: The inputs this agent expects, e.g., "a task to implement" or "a question to answer".
# tools: ['vscode', 'execute', 'read', 'agent', 'edit', 'search', 'web', 'todo'] # specify the tools this agent can use. If not set, all enabled tools are allowed.
---

<!-- Tip: Use /create-agent in chat to generate content with agent assistance -->

Responsibility: All SwiftUI Views — every screen, every reusable component. Owns design system implementation.
Deliverables: All files in Views/ — 10 Swift files total.
Prompt:
You are the UI Agent for the BookBase iOS app.
Your job is to generate all SwiftUI view files.
You receive the data models and ViewModel from the Structure Agent.
You receive the design system spec below.
Generate ALL view files completely — no truncation, no TODOs.
Every interactive element must have an accessibilityLabel.
Never use force-unwraps. Never leave placeholder comments.

6. Screen Specifications
Screen 1 — Discover / HomeView (Tab 1)
Dicoding role: "Halaman Utama" — must show ≥10 items with title + image in list/scroll format
NavigationStack
└── ScrollView (vertical)
    ├── OfflineBannerView (conditional, when isOfflineMode == true)
    ├── SearchBar (TextField + clear button, live filter on keystroke)
    ├── CategoryChips (horizontal ScrollView, green bg #F0FDF4)
    │   └── GenreChipView × 10 genres
    ├── "Featured" section header
    │   └── horizontal ScrollView
    │       └── FeaturedCardView × isFeatured books (260×160pt)
    └── "Recommended" / "Results" section
        ├── loading → BookCardSkeleton × 6 (shimmer)
        ├── empty  → EmptyStateView + "Clear filters" CTA
        ├── error  → warning icon + message + Retry button
        └── success → horizontal ScrollView
                      └── BookCardView × filteredBooks (140×200pt cover)
State variations:

.loading → shimmer skeletons in both shelves
.success([]) + filters active → EmptyStateView("No books found", "Clear filters")
.error(msg) → Image(systemName:"exclamationmark.triangle") + Button("Retry")
isOfflineMode → OfflineBannerView orange capsule at top

Navigation: Every BookCardView and FeaturedCardView wrapped in NavigationLink(destination: BookDetailView(book:))

Screen 2 — Browse / BrowseView (Tab 2)
Dicoding role: Satisfies "format List" criterion — uses SwiftUI List
NavigationStack
└── VStack
    ├── genre filter bar (horizontal ScrollView, white bg, bottom divider)
    │   └── GenreChipView × 10
    └── List (filteredBooks)
        └── ForEach → NavigationLink → BookRowView
            ├── cover thumbnail (56×80pt, AsyncImage)
            ├── title (subheadline semibold, 2 lines)
            ├── author (caption, textSecondary)
            └── genre badge + StarRatingView
            .swipeActions(edge: .trailing) → heart button (favorite toggle)

Screen 3 — Book Detail / BookDetailView (pushed)
Dicoding role: "Halaman Detail" — shows detailed information, uses SwiftUI layout
NavigationStack push → ScrollView (vertical, ignoresSafeArea .top)
├── toolbar: [← Back] .............. [♡ favorite] [share]
├── GeometryReader → parallax cover (280pt height)
│   AsyncImage phases: .empty→shimmer / .success→image / .failure→placeholder
│   LinearGradient overlay (clear → black 0.35, bottom)
└── Content VStack (padding 20pt)
    ├── title (.system 24pt bold)
    ├── author (.system 15pt, textSecondary)
    ├── StarRatingView (18pt stars, showNumeric: true)
    ├── Stats row: Pages | Rating | Genre (white card, border, radius 12)
    ├── Genre capsule tags
    ├── Divider
    ├── "Synopsis" header + full body text (lineSpacing 4)
    ├── Divider
    ├── "Read Now" button (blue full-width, radius 14)
    └── "Add to Library / Saved" toggle button (white, border, toggles red)
State variations:

Cover .failure → Image(systemName: "book.closed.fill") + title text
isFavorite == true → red heart, "Saved to Library" label, red border
Share button → ShareSheetView (UIActivityViewController) with text: "Check out "\(title)" by \(author)..."


Screen 4 — Library / LibraryView (Tab 3)
NavigationStack
├── if favoriteBooks.isEmpty → EmptyStateView
│   ("heart.slash", "No books saved yet",
│    "Tap the heart on any book to save it here.",
│    CTA: "Browse Books")
└── else → ScrollView
    └── VStack
        ├── count label ("\(n) saved book(s)")
        └── LazyVGrid (2 columns, spacing 20)
            └── ForEach favoriteBooks → NavigationLink → LibraryBookCard
                ├── ZStack(topTrailing)
                │   ├── AsyncImage cover (height 180, radius 12)
                │   └── heart button (white circle badge, top-right)
                └── title (caption semibold, 2 lines) + author (caption2)
Persistence: On every toggleFavorite, HomeViewModel saves IDs to UserDefaults and re-loads on app launch.

Screen 5 — About / AboutView (Tab 4)
Dicoding role: "Halaman About" — mandatory: real developer name + real photo
NavigationStack
└── ScrollView
    ├── developer photo (110pt circle, Assets: "developer_photo")
    │   fallback: initials circle (primaryBlue.opacity(0.15) bg)
    ├── developer REAL NAME (.title2 bold) ← MANDATORY
    ├── role subtitle (primaryBlue)
    ├── "About Me" section + 2–3 sentence real bio
    ├── "Connect" section
    │   ├── Link row: GitHub
    │   ├── Link row: LinkedIn
    │   └── Link row: Email
    └── app version footer (Bundle version, "Built with SwiftUI")

⚠️ UI Agent must add this comment in AboutView.swift:
swift// TODO (developer): Replace "Your Real Full Name", bio text,
// and add real photo to Assets catalog as "developer_photo" imageset
// before submitting to Dicoding. Missing real name/photo = REJECTED.


Reusable Components
BookCardView — 140×200pt cover + title (2 lines) + author + StarRatingView (11pt, no numeric)

AsyncImage with 3 phase states (shimmer / image / placeholder)
.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
.accessibilityElement(children: .combine) + label

FeaturedCardView — 260×160pt, gradient overlay, title + author + stars on dark bg
StarRatingView — 5 stars, SF Symbols: star.fill, star.leadinghalf.filled, star

Amber #F59E0B, 14pt default
init(rating: Double, maxRating: Int = 5, starSize: CGFloat = 14, showNumeric: Bool = true)

ShimmerView — LinearGradient animated phase offset, .repeatForever(autoreverses: false)
BookCardSkeleton — gray rounded rects mimicking card layout, .shimmer(isLoading: true)
GenreChipView — Capsule, selected = primaryBlue fill/white text, unselected = white/border

.accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)

EmptyStateView — SF Symbol (large) + title + subtitle + optional CTA button
OfflineBannerView — Orange Capsule: wifi.slash icon + "Offline mode — showing saved books"
ShareSheetView — UIViewControllerRepresentable wrapping UIActivityViewController
BookRowView — for BrowseView list rows: 56×80pt cover + title + author + badge + stars + swipe action

ContentView (TabView Root)
swift// Views/ContentView.swift
// ⚠️ This file goes in Views/ ONLY.
// Delete BookBase/ContentView.swift (Xcode auto-generated) before adding this.

TabView(selection: $selectedTab) {
    HomeView()   .tabItem { Label("Discover", systemImage: "house.fill") }        .tag(0)
    BrowseView() .tabItem { Label("Browse",   systemImage: "books.vertical.fill") }.tag(1)
    LibraryView().tabItem { Label("Library",  systemImage: "heart.fill") }         .tag(2)
    AboutView()  .tabItem { Label("About",    systemImage: "person.circle.fill") } .tag(3)
}
.tint(Color.primaryBlue)
.environment(viewModel)   // passed in from BookBaseApp