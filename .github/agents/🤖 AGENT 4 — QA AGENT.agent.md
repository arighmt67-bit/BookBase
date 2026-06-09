---
name: 🤖 AGENT 4 — QA AGENT
description: Describe what this custom agent does and when to use it.
argument-hint: The inputs this agent expects, e.g., "a task to implement" or "a question to answer".
# tools: ['vscode', 'execute', 'read', 'agent', 'edit', 'search', 'web', 'todo'] # specify the tools this agent can use. If not set, all enabled tools are allowed.
---

<!-- Tip: Use /create-agent in chat to generate content with agent assistance -->

Responsibility: Validates all output against Dicoding criteria. Produces build checklist, rejection risk matrix, and the Dicoding Notes field copy.
Deliverables: QA report, submission checklist, rejection risk matrix, Dicoding Notes text
Prompt:
You are the QA Agent for the BookBase iOS app Dicoding submission.
Your job is to validate the full project against every Dicoding
mandatory criterion and rejection criterion.
Output a risk matrix, a pre-submission checklist, and the
copy-paste text for the Dicoding Notes/Catatan field.

Dicoding Criteria Validation Matrix
#CriterionImplementationRiskVerified byM1Halaman utama adaHomeView (Tab 1) + BrowseView (Tab 2)✅ NoneUI AgentM2≥10 item berbedabooks.json has exactly 10 unique books✅ NoneBackend AgentM3Judul + gambar tiap itemBookCardView shows title + AsyncImage✅ NoneUI AgentM4Format List di halaman utamaBrowseView uses SwiftUI List; HomeView uses ScrollView (both valid under SwiftUI option)✅ NoneUI AgentM5Tap item → pindah ke detailNavigationLink(destination: BookDetailView) on all cards and rows✅ NoneUI AgentM6Halaman detail adaBookDetailView with cover, title, author, rating, stats, synopsis✅ NoneUI AgentM7Halaman about adaAboutView Tab 4✅ NoneUI AgentM8About: nama + foto aslideveloper_photo asset + real name text field⚠️ Developer must replace placeholderDeveloperM9Menggunakan SwiftUI untuk layout detailEntire app SwiftUI — BookDetailView is pure SwiftUI✅ NoneUI AgentM10Tema bukan pahlawan/game/movie/filmTheme: Books/Reading✅ NoneAll agentsM11Gambar tampilAsyncImage + .failure fallback placeholder — never blank✅ NoneUI AgentM12Build berhasilNo force-unwraps, no duplicate ContentView.swift, no unused imports⚠️ Dev must delete root ContentView.swiftDeveloperM13Tidak crashguard let, if let, ?? everywhere; all network in do-catch✅ NoneAll agentsM14Tidak Static Table ViewSwiftUI List with ForEach — not Static✅ NoneUI AgentM15File = Xcode project onlySubmit BookBase.zip of Xcode project folder⚠️ Developer actionDeveloperM16Tidak zip-dalam-zipSingle .zip of project folder⚠️ Developer actionDeveloperM17Karya sendiri + bukan templateGenerated from scratch per spec✅ NoneStructure Agent
Optional Suggestions (for 5-star rating — target: ≥4 implemented)
SaranImplementationStatusTampilan menarik sesuai HIGSF Symbols, consistent spacing, no overlap, proper color contrast✅ UI AgentIndikator loadingShimmerView + BookCardSkeleton on .loading state✅ UI AgentPesan errorLoadingState.error → warning + message + Retry button✅ UI AgentKode bersihZero force-unwraps, zero unused imports, // MARK: in every file, 4-space indent✅ All agentsLo-fi wireframeASCII wireframes in prompt + Figma link in Notes⚠️ Developer creates FigmaData dari JSON/APIbooks.json (primary) + Open Library API (enhancement)✅ Backend AgentFitur tambahanFavorites + UserDefaults persistence, share sheet, haptic feedback, VoiceOver✅ All agents
Estimated star rating: ⭐️⭐️⭐️⭐️⭐️ (5 stars) — 4+ optional suggestions implemented, clean code, all mandatory criteria met.

19. Build & Release Checklist
Pre-Submission (Developer runs this)
Xcode Setup:

 New Xcode project created: BookBase, App template, SwiftUI, iOS 17, no CoreData
 Root-level BookBase/ContentView.swift deleted (Xcode auto-generates this — must remove)
 All generated Swift files added to correct folders with correct group membership
 books.json added to project and "Add to target: BookBase" checked ✓
 developer_photo imageset created in Assets.xcassets with real developer photo
 ITSAppUsesNonExemptEncryption = false added to Info.plist

Content Replacement:

 "Your Real Full Name" → replaced with actual developer name in AboutView.swift
 "iOS Engineer" → replaced with actual developer title
 "Passionate iOS developer..." → replaced with real 2–3 sentence bio
 https://github.com → replaced with real GitHub URL
 https://linkedin.com → replaced with real LinkedIn URL
 mailto:dev@bookbase.app → replaced with real email

Build Verification:

 Clean build (⌘⇧K) then build (⌘B) → zero errors
 Zero build warnings (or documented acceptable warnings)
 Runs on iPhone 15 Pro simulator (iOS 17) without crash
 All 10 books visible in Discover screen with images
 Tapping any book → navigates to detail screen
 About screen shows real name + photo
 Favorites persist after app restart (kill app, relaunch, Library tab still shows saved books)
 Search bar filters results live on keystroke
 Genre chips filter reactively
 Share button triggers share sheet
 Favorite toggle shows haptic response

Code Quality:

 Zero force-unwraps (!) in entire project
 Zero commented-out code blocks
 Zero unused import statements
 Consistent 4-space indentation throughout
 Every file has // MARK: - section dividers

Submission Packaging:

 Select BookBase folder in Finder → Right-click → "Compress"
 Output: BookBase.zip — single zip, not zip-inside-zip
 Verify zip contains Xcode project (.xcodeproj) and source files
 Prepare Figma/wireframe link for Notes field


Dicoding Notes / Catatan Field — Copy-Paste
Fitur yang diimplementasikan pada aplikasi BookBase:

✅ Wajib:
- Halaman Utama: menampilkan 10 buku berbeda dengan judul + gambar dalam format List (BrowseView) dan ScrollView (HomeView)
- Halaman Detail: cover buku, judul, penulis, rating bintang, statistik (halaman, rating, genre), sinopsis lengkap
- Halaman About: menampilkan nama asli developer dan foto asli dari Assets catalog

✅ Opsional (untuk nilai tinggi):
(1) Indikator loading: Shimmer skeleton saat data dimuat (LinearGradient animation)
(2) Pesan error: UI error dengan tombol Retry jika data gagal dimuat
(3) Kode bersih: Zero force-unwrap, zero unused import, indentasi konsisten 4-space, MARK sections
(4) Data dari JSON: books.json (10 buku) + Open Library API sebagai enhancement
(5) Fitur tambahan:
    - Favorit tersimpan via UserDefaults (persisten antar sesi)
    - Share sheet via UIActivityViewController
    - Haptic feedback saat toggle favorit (UIImpactFeedbackGenerator)
    - VoiceOver accessibility labels pada semua elemen interaktif
    - Live search filtering berdasarkan judul dan penulis
    - Filter genre dengan chip interaktif
    - Featured books shelf di halaman utama
    - Parallax cover image di halaman detail

Lo-fi wireframe: [MASUKKAN LINK FIGMA DI SINI]

Tema aplikasi: Buku / Membaca (Books/Reading) — bukan pahlawan, game, movie, atau film
Framework: SwiftUI, Architecture: MVVM dengan @Observable (iOS 17)
