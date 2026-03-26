import SwiftUI

/// Abstracts image loading and caching for testability and performance.
/// Live implementation uses NSCache with size-appropriate artwork requests.
protocol ImageCacheProtocol: Sendable {

    /// Loads an image for the given artwork source at the specified display size.
    /// Returns cached image immediately if available, otherwise fetches from network.
    /// - Parameters:
    ///   - source: The artwork source containing the URL template.
    ///   - width: Display width in points (will be multiplied by scale factor internally).
    ///   - height: Display height in points.
    func image(for source: ArtworkSource?, width: CGFloat, height: CGFloat) async -> UIImage?

    /// Returns a cached image synchronously, or nil if not cached.
    /// Use this for scroll-performance-critical paths where async loading isn't acceptable.
    func cachedImage(for source: ArtworkSource?, width: CGFloat, height: CGFloat) -> UIImage?

    /// Removes all cached images. Called on memory warnings.
    func clearCache()
}
