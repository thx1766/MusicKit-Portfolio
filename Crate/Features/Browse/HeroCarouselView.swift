import SwiftUI

/// Auto-advancing hero carousel using TabView with page style.
/// Displays featured content at the top of the Browse screen.
struct HeroCarouselView: View {
    let items: [HeroItem]

    @Environment(Router.self) private var router
    @State private var currentIndex = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HeroCardView(item: item)
                    .onTapGesture {
                        router.navigate(to: item.route)
                    }
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 220)
        .accessibilityLabel("Featured content carousel")
    }
}

// MARK: - Hero Card

struct HeroCardView: View {
    let item: HeroItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ArtworkImageView(
                source: item.artworkSource,
                width: UIScreen.main.bounds.width - 32,
                height: 220,
                cornerRadius: 12
            )

            // Gradient overlay for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding()
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.subtitle)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to open")
    }
}
