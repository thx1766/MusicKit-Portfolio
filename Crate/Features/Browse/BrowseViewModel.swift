import Foundation

/// View model for the Browse/Discovery screen.
/// Loads chart data from the catalog service and manages loading states per section.
@Observable
final class BrowseViewModel {
    private let catalogService: any CatalogServiceProtocol

    // Chart sections — each loads independently for progressive rendering
    var albumSection: ChartSection<AlbumItem>?
    var playlistSection: ChartSection<PlaylistItem>?
    var songSection: ChartSection<SongItem>?

    var isLoading = false
    var error: Error?

    init(catalogService: any CatalogServiceProtocol) {
        self.catalogService = catalogService
    }

    /// Loads all chart sections. Sections populate progressively as data arrives.
    @MainActor
    func loadCharts() async {
        isLoading = true
        error = nil

        do {
            let charts = try await catalogService.fetchCharts(limit: 25)
            albumSection = charts.albums
            playlistSection = charts.playlists
            songSection = charts.songs
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Refreshes all charts data. Used by pull-to-refresh.
    @MainActor
    func refresh() async {
        await loadCharts()
    }

    /// Hero items for the carousel — takes first few playlists or albums with artwork.
    var heroItems: [HeroItem] {
        let fromPlaylists: [HeroItem] = (playlistSection?.items ?? []).prefix(5).map { playlist in
            HeroItem(
                id: playlist.id,
                title: playlist.name,
                subtitle: playlist.curatorName ?? "",
                artworkSource: playlist.artworkURL,
                route: .playlist(id: playlist.id)
            )
        }

        let fromAlbums: [HeroItem] = (albumSection?.items ?? []).prefix(3).map { album in
            HeroItem(
                id: album.id,
                title: album.title,
                subtitle: album.artistName,
                artworkSource: album.artworkURL,
                route: .album(id: album.id)
            )
        }

        return Array((fromPlaylists + fromAlbums).prefix(6))
    }
}

// MARK: - Hero Item

struct HeroItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let artworkSource: ArtworkSource?
    let route: Route
}
