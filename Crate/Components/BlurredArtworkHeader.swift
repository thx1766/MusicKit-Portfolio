import SwiftUI

/// Large artwork header with blurred background effect for detail views.
/// The artwork is displayed prominently with a blurred, dimmed version behind it.
struct BlurredArtworkHeader: View {
    let artworkSource: ArtworkSource?
    let title: String
    let subtitle: String
    var metadata: String?

    @Environment(\.services) private var services
    @State private var backgroundImage: UIImage?

    var body: some View {
        ZStack(alignment: .bottom) {
            // Blurred background
            backgroundLayer
                .frame(height: 380)

            // Content overlay
            VStack(spacing: 12) {
                ArtworkImageView(
                    source: artworkSource,
                    width: 220,
                    height: 220,
                    cornerRadius: 12
                )
                .shadow(radius: 16, y: 8)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)

                    if let metadata {
                        Text(metadata)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let backgroundImage {
            Image(uiImage: backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.4))
                .blur(radius: 40)
                .clipped()
        } else {
            Rectangle()
                .fill(.linearGradient(
                    colors: [.gray.opacity(0.6), .gray.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
        }
    }
}

#Preview {
    BlurredArtworkHeader(
        artworkSource: nil,
        title: "Midnights",
        subtitle: "Taylor Swift",
        metadata: "2022 · 13 songs"
    )
    .environment(\.services, .preview)
}
