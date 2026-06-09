import SwiftUI

// MARK: - AboutView

struct AboutView: View {

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    profileHeader
                    Divider().padding(.horizontal, 24)
                    bioSection
                    Divider().padding(.horizontal, 24)
                    interestsSection
                    Divider().padding(.horizontal, 24)
                    appInfoSection
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.backgroundMain)
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Developer photo (from Assets: developer_photo)
            Group {
                if let uiImage = UIImage(named: "developer_photo") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    // Fallback initials avatar
                    ZStack {
                        Circle()
                            .fill(Color.primaryBlue.opacity(0.15))
                        Text("AR")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(Color.primaryBlue)
                    }
                }
            }
            .frame(width: 110, height: 110)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .accessibilityLabel("Developer profile photo")

            VStack(spacing: 6) {
                Text("Ari Rahmat Romadhon")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("Mobile & Cloud Engineer")
                    .font(.subheadline)
                    .foregroundStyle(Color.primaryBlue)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.textSecondary)
                    Text("Kota Tangerang")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .accessibilityLabel("Location: Kota Tangerang")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
    }

    // MARK: - Bio Section

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tentang Saya")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text("Halo! Nama saya Ari Rahmat Romadhon, seorang pengembang yang berdomisili di Kota Tangerang. Saya memiliki ketertarikan yang mendalam di bidang Mobile Engineering dan Cloud Engineering. Saat ini saya sedang mendalami pengembangan aplikasi iOS native menggunakan SwiftUI, dan BookBase adalah proyek iOS pertama saya yang dibangun sebagai bagian dari kelas Belajar Pengembangan Aplikasi iOS Pemula di Dicoding.")
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    // MARK: - Interests Section

    private var interestsSection: some View {
        VStack(spacing: 16) {
            Text("Minat & Keahlian")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                interestChip(icon: "iphone", label: "Mobile Engineer")
                interestChip(icon: "cloud.fill", label: "Cloud Engineer")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private func interestChip(icon: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.primaryBlue)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel("\(label) interest")
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "books.vertical.fill")
                        .foregroundStyle(Color.primaryBlue)
                        .accessibilityHidden(true)
                    Text("BookBase")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)
                }

                Text("Version \(appVersion)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                Text("Dibangun untuk Dicoding Academy")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.vertical, 20)
        }
    }

    // MARK: - App Version

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - Preview

#Preview {
    AboutView()
}
