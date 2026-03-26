import Foundation

// MARK: - Display Models
// Lightweight value types that view models produce from MusicKit types.
// These decouple views from MusicKit, enabling testability (MusicKit types lack public initializers).

nonisolated struct AlbumItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artistName: String
    let artworkURL: ArtworkSource?
    let releaseDate: Date?
    let trackCount: Int
    let genreNames: [String]

    static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

nonisolated struct SongItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: ArtworkSource?
    let duration: TimeInterval?
    let trackNumber: Int?

    static func == (lhs: SongItem, rhs: SongItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

nonisolated struct ArtistItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let artworkURL: ArtworkSource?
    let genreNames: [String]
}

nonisolated struct PlaylistItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let curatorName: String?
    let description: String?
    let artworkURL: ArtworkSource?
    let trackCount: Int

    static func == (lhs: PlaylistItem, rhs: PlaylistItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

nonisolated struct StationItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let artworkURL: ArtworkSource?
}

// MARK: - Artwork Source

/// Wraps MusicKit Artwork into a Sendable, testable type.
/// Stores the base URL template so we can request sized images later.
nonisolated struct ArtworkSource: Hashable, Sendable {
    let urlTemplate: String?
    let width: Int?
    let height: Int?

    func url(width: Int, height: Int) -> URL? {
        guard let template = urlTemplate else { return nil }
        // MusicKit artwork URLs use {w}x{h} placeholder pattern
        let urlString = template
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
        return URL(string: urlString)
    }
}

// MARK: - Chart Section

nonisolated struct ChartSection<Item: Identifiable & Hashable & Sendable>: Identifiable, Sendable {
    let id: String
    let title: String
    var items: [Item]
    var hasNextBatch: Bool
}

// MARK: - Search Results

nonisolated struct SearchResults: Sendable {
    var songs: [SongItem] = []
    var albums: [AlbumItem] = []
    var artists: [ArtistItem] = []
    var playlists: [PlaylistItem] = []

    var isEmpty: Bool {
        songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty
    }
}

// MARK: - Now Playing State

nonisolated struct NowPlayingState: Sendable {
    let title: String
    let artistName: String
    let artworkURL: ArtworkSource?
    let isPlaying: Bool
    let playbackTime: TimeInterval
    let duration: TimeInterval?
}
