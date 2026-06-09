import SwiftUI

// MARK: - StarRatingView

struct StarRatingView: View {

    // MARK: - Properties

    let rating: Double
    let maxRating: Int
    let starSize: CGFloat
    let showNumeric: Bool

    // MARK: - Init

    init(
        rating: Double,
        maxRating: Int = 5,
        starSize: CGFloat = 14,
        showNumeric: Bool = true
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.starSize = starSize
        self.showNumeric = showNumeric
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 3) {
            HStack(spacing: 2) {
                ForEach(1...maxRating, id: \.self) { index in
                    starImage(for: index)
                        .font(.system(size: starSize))
                        .foregroundStyle(Color.starAmber)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rating: \(String(format: "%.1f", rating)) out of \(maxRating) stars")

            if showNumeric {
                Text(String(format: "%.1f", rating))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Star Image Helper

    private func starImage(for index: Int) -> Image {
        let threshold = Double(index)
        if rating >= threshold {
            return Image(systemName: "star.fill")
        } else if rating >= threshold - 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        StarRatingView(rating: 4.7)
        StarRatingView(rating: 3.5)
        StarRatingView(rating: 2.0, showNumeric: false)
        StarRatingView(rating: 5.0, starSize: 20)
    }
    .padding()
}
