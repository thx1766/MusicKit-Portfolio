import Foundation

/// Mock catalog service for previews and unit tests.
/// Provides configurable responses and simulated delays.
final class MockCatalogService: CatalogServiceProtocol, @unchecked Sendable {

    var chartsDelay: Duration = .milliseconds(500)
    var shouldThrowError = false

    func fetchCharts(limit: Int) async throws -> (
        albums: ChartSection<AlbumItem>,
        playlists: ChartSection<PlaylistItem>,
        songs: ChartSection<SongItem>
    ) {
        try await Task.sleep(for: chartsDelay)
        if shouldThrowError { throw MockError.simulated }

        return (
            albums: ChartSection(
                id: "mock-albums",
                title: "Top Albums",
                items: Self.sampleAlbums,
                hasNextBatch: false
            ),
            playlists: ChartSection(
                id: "mock-playlists",
                title: "Top Playlists",
                items: Self.samplePlaylists,
                hasNextBatch: false
            ),
            songs: ChartSection(
                id: "mock-songs",
                title: "Top Songs",
                items: Self.sampleSongs,
                hasNextBatch: false
            )
        )
    }

    func fetchNextBatch<T: Identifiable & Hashable & Sendable>(
        for section: ChartSection<T>
    ) async throws -> ChartSection<T> {
        return section
    }

    func fetchAlbum(id: String) async throws -> (album: AlbumItem, tracks: [SongItem]) {
        try await Task.sleep(for: .milliseconds(300))
        if shouldThrowError { throw MockError.simulated }

        let album = Self.sampleAlbums.first { $0.id == id } ?? Self.sampleAlbums[0]
        return (album, Self.sampleSongs)
    }

    func fetchArtist(id: String) async throws -> (
        artist: ArtistItem,
        topSongs: [SongItem],
        albums: [AlbumItem]
    ) {
        try await Task.sleep(for: .milliseconds(300))
        if shouldThrowError { throw MockError.simulated }

        let artist = Self.sampleArtists.first { $0.id == id } ?? Self.sampleArtists[0]
        return (artist, Self.sampleSongs, Self.sampleAlbums)
    }

    func fetchPlaylist(id: String) async throws -> (playlist: PlaylistItem, tracks: [SongItem]) {
        try await Task.sleep(for: .milliseconds(300))
        if shouldThrowError { throw MockError.simulated }

        let playlist = Self.samplePlaylists.first { $0.id == id } ?? Self.samplePlaylists[0]
        return (playlist, Self.sampleSongs)
    }

    func fetchRelatedAlbums(for albumID: String, limit: Int) async throws -> [AlbumItem] {
        try await Task.sleep(for: .milliseconds(200))
        return Array(Self.sampleAlbums.prefix(limit))
    }
}

// MARK: - Sample Data

extension MockCatalogService {

    static let sampleAlbums: [AlbumItem] = (1...10).map { i in
        AlbumItem(
            id: "album-\(i)",
            title: "Album \(i)",
            artistName: "Artist \(i)",
            artworkURL: nil,
            releaseDate: Date(),
            trackCount: 12,
            genreNames: ["Pop"]
        )
    }

    static let sampleSongs: [SongItem] = (1...15).map { i in
        SongItem(
            id: "song-\(i)",
            title: "Song \(i)",
            artistName: "Artist \((i % 5) + 1)",
            albumTitle: "Album \((i % 3) + 1)",
            artworkURL: nil,
            duration: TimeInterval(180 + i * 10),
            trackNumber: i
        )
    }

    static let sampleArtists: [ArtistItem] = (1...5).map { i in
        ArtistItem(
            id: "artist-\(i)",
            name: "Artist \(i)",
            artworkURL: nil,
            genreNames: ["Pop", "Rock"]
        )
    }

    static let samplePlaylists: [PlaylistItem] = (1...8).map { i in
        PlaylistItem(
            id: "playlist-\(i)",
            name: "Playlist \(i)",
            curatorName: "Apple Music",
            description: "A curated selection of great tracks.",
            artworkURL: nil,
            trackCount: 25
        )
    }
}

// MARK: - Mock Error

enum MockError: LocalizedError {
    case simulated

    var errorDescription: String? { "A simulated error occurred." }
}
