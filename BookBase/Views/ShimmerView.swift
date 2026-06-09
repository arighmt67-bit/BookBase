import SwiftUI

// MARK: - ShimmerView

struct ShimmerView: View {

    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.15),
                    Color.gray.opacity(0.30),
                    Color.gray.opacity(0.15)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 3)
            .offset(x: phase * geo.size.width * 3)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
        .clipped()
    }
}

// MARK: - ShimmerModifier

struct ShimmerModifier: ViewModifier {
    var isLoading: Bool

    func body(content: Content) -> some View {
        if isLoading {
            content.overlay(ShimmerView())
        } else {
            content
        }
    }
}

extension View {
    func shimmer(isLoading: Bool) -> some View {
        modifier(ShimmerModifier(isLoading: isLoading))
    }
}

// MARK: - BookCardSkeleton

struct BookCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .frame(width: AppConstants.cardWidth, height: AppConstants.cardCoverHeight)
                .shimmer(isLoading: true)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.15))
                .frame(width: AppConstants.cardWidth, height: 14)
                .shimmer(isLoading: true)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.15))
                .frame(width: AppConstants.cardWidth * 0.7, height: 12)
                .shimmer(isLoading: true)
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        BookCardSkeleton()
        BookCardSkeleton()
    }
    .padding()
}
