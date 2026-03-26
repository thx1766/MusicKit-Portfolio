import Foundation

/// Abstracts Apple Music catalog operations for testability.
/// Live implementation wraps MusicKit's `MusicCatalogChartsRequest` and `MusicCatalogResourceRequest`.
protocol CatalogServiceProtocol: Sendable {

    /// Fetches top charts for the browse screen.
    /// Returns album, playlist, and song chart sections.
    func fetchCharts(limit: Int) async throws -> (
        albums: ChartSection<AlbumItem>,
        playlists: ChartSection<PlaylistItem>,
        songs: ChartSection<SongItem>
    )

    /// Loads the next batch of items for a chart section.
    func fetchNextBatch<T: Identifiable & Hashable & Sendable>(
        for section: ChartSection<T>
    ) async throws -> ChartSection<T>

    /// Fetches full album detail including tracks.
    func fetchAlbum(id: String) async throws -> (album: AlbumItem, tracks: [SongItem])

    /// Fetches artist detail including top songs and albums.
    func fetchArtist(id: String) async throws -> (
        artist: ArtistItem,
        topSongs: [SongItem],
        albums: [AlbumItem]
    )

    /// Fetches playlist detail including tracks.
    func fetchPlaylist(id: String) async throws -> (playlist: PlaylistItem, tracks: [SongItem])

    /// Fetches albums related to a given album (by genre or artist).
    func fetchRelatedAlbums(for albumID: String, limit: Int) async throws -> [AlbumItem]
}
