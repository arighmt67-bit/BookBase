import SwiftUI

// MARK: - GenreChipView

struct GenreChipView: View {

    let genre: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(genre)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.primaryBlue : Color.white)
                .foregroundStyle(isSelected ? Color.white : Color.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.primaryBlue : Color.borderColor, lineWidth: 1)
                )
        }
        .accessibilityLabel("\(genre) genre filter\(isSelected ? ", selected" : "")")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {

    let systemImage: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(Color.primaryBlue.opacity(0.4))
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel(actionTitle)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - OfflineBannerView

struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.caption)
                .accessibilityHidden(true)
            Text("Offline mode — showing saved books")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange)
        .clipShape(Capsule())
        .accessibilityLabel("Offline mode. Showing saved books.")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        HStack {
            GenreChipView(genre: "All", isSelected: true) {}
            GenreChipView(genre: "Sci-Fi", isSelected: false) {}
        }
        EmptyStateView(
            systemImage: "heart.slash",
            title: "No books saved yet",
            subtitle: "Tap the heart on any book to add it to your library.",
            actionTitle: "Browse Books",
            action: {}
        )
        OfflineBannerView()
    }
    .padding()
}
