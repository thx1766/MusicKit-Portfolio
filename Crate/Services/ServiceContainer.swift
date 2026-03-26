import SwiftUI

/// Central dependency container injected through SwiftUI Environment.
/// Holds all service instances, swappable between live and mock for testing/previews.
@Observable
final class ServiceContainer: @unchecked Sendable {
    let catalog: any CatalogServiceProtocol
    let search: any SearchServiceProtocol
    let player: any PlayerServiceProtocol
    let imageCache: any ImageCacheProtocol

    init(
        catalog: any CatalogServiceProtocol,
        search: any SearchServiceProtocol,
        player: any PlayerServiceProtocol,
        imageCache: any ImageCacheProtocol
    ) {
        self.catalog = catalog
        self.search = search
        self.player = player
        self.imageCache = imageCache
    }

    /// Live services using MusicKit.
    static let live = ServiceContainer(
        catalog: MusicCatalogService(),
        search: MusicSearchService(),
        player: MusicPlayerService(),
        imageCache: ArtworkImageCache()
    )

    /// Mock services for previews and tests.
    static let preview = ServiceContainer(
        catalog: MockCatalogService(),
        search: MockSearchService(),
        player: MockPlayerService(),
        imageCache: MockImageCache()
    )
}

// MARK: - Environment Key

private struct ServiceContainerKey: EnvironmentKey {
    static let defaultValue = ServiceContainer.live
}

extension EnvironmentValues {
    var services: ServiceContainer {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}
