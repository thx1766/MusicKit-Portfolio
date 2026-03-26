import SwiftUI

/// Animated shimmer placeholder shown while content loads.
/// Supports Reduce Motion by falling back to a static gray.
struct SkeletonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            if reduceMotion {
                Rectangle()
                    .fill(Color(.systemGray5))
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        shimmerGradient
                            .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                    )
                    .clipped()
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            isAnimating = true
                        }
                    }
            }
        }
    }

    private var shimmerGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemGray5).opacity(0),
                Color(.systemGray4).opacity(0.5),
                Color(.systemGray5).opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 100)
    }
}

// MARK: - Skeleton Modifier

/// Apply to any view to show a skeleton placeholder while loading.
struct SkeletonModifier: ViewModifier {
    let isLoading: Bool
    var cornerRadius: CGFloat = 8

    func body(content: Content) -> some View {
        if isLoading {
            content
                .hidden()
                .overlay(
                    SkeletonView()
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                )
        } else {
            content
        }
    }
}

extension View {
    func skeleton(isLoading: Bool, cornerRadius: CGFloat = 8) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: 16) {
        SkeletonView()
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))

        Text("Hello World")
            .skeleton(isLoading: true)
    }
    .padding()
}
