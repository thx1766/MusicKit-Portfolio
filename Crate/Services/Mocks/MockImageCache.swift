import UIKit

/// Mock image cache that returns placeholder colors for previews.
final class MockImageCache: ImageCacheProtocol, @unchecked Sendable {

    func image(for source: ArtworkSource?, width: CGFloat, height: CGFloat) async -> UIImage? {
        // Return a colored placeholder for previews
        try? await Task.sleep(for: .milliseconds(200))
        return makePlaceholder(width: width, height: height)
    }

    func cachedImage(for source: ArtworkSource?, width: CGFloat, height: CGFloat) -> UIImage? {
        makePlaceholder(width: width, height: height)
    }

    func clearCache() {}

    private func makePlaceholder(width: CGFloat, height: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { context in
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        }
    }
}
