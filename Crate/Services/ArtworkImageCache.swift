import UIKit

/// NSCache-based image cache that requests appropriately sized artwork.
/// Keys are URL strings to avoid loading oversized images for small views.
final class ArtworkImageCache: ImageCacheProtocol, @unchecked Sendable {

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    init(countLimit: Int = 200, totalCostLimit: Int = 100 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit // 100 MB default

        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50 MB memory
            diskCapacity: 200 * 1024 * 1024     // 200 MB disk
        )
        session = URLSession(configuration: config)
    }

    func image(for source: ArtworkSource?, width: CGFloat, height: CGFloat) async -> UIImage? {
        guard let source else { return nil }

        let scale = await MainActor.run { UIScreen.main.scale }
        let pixelWidth = Int(width * scale)
        let pixelHeight = Int(height * scale)

        guard let url = source.url(width: pixelWidth, height: pixelHeight) else { return nil }
        let key = url.absoluteString as NSString

        // Check cache first
        if let cached = cache.object(forKey: key) {
            return cached
        }

        // Fetch from network
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            let cost = data.count
            cache.setObject(image, forKey: key, cost: cost)
            return image
        } catch {
            return nil
        }
    }

    func cachedImage(for source: ArtworkSource?, width: CGFloat, height: CGFloat) -> UIImage? {
        guard let source else { return nil }

        // Use a reasonable default scale for synchronous access
        let pixelWidth = Int(width * 2)
        let pixelHeight = Int(height * 2)

        guard let url = source.url(width: pixelWidth, height: pixelHeight) else { return nil }
        return cache.object(forKey: url.absoluteString as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
