import SwiftUI

/// Cached artwork image view that requests size-appropriate images.
/// Uses the image cache from the environment to avoid redundant network requests.
struct ArtworkImageView: View {
    let source: ArtworkSource?
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 8

    @Environment(\.services) private var services
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                SkeletonView()
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .accessibilityHidden(true)
        .task(id: source) {
            image = await services.imageCache.image(
                for: source, width: width, height: height
            )
        }
    }
}

#Preview {
    ArtworkImageView(source: nil, width: 150, height: 150)
        .environment(\.services, .preview)
}
