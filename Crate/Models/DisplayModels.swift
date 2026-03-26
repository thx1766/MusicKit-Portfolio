import Foundation
import SwiftUI

// MARK: - Display Models
// Lightweight value types that view models produce from MusicKit types.
// These decouple views from MusicKit, enabling testability (MusicKit types lack public initializers).

struct AlbumItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artistName: String
    let artworkURL: ArtworkSource?
    let releaseDate: Date?
    let trackCount: Int
    let genreNames: [String]
}

struct SongItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: ArtworkSource?
    let duration: TimeInterval?
    let trackNumber: Int?
}

struct ArtistItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let artworkURL: ArtworkSource?
    let genreNames: [String]
}

struct PlaylistItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let curatorName: String?
    let description: String?
    let artworkURL: ArtworkSource?
    let trackCount: Int
}

struct StationItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let artworkURL: ArtworkSource?
}

// MARK: - Artwork Source

/// Wraps MusicKit Artwork into a Sendable, testable type.
/// Stores the base URL template so we can request sized images later.
struct ArtworkSource: Hashable, Sendable {
    let urlTemplate: String?
    let backgroundColor: Color?
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

struct ChartSection<Item: Identifiable & Hashable & Sendable>: Identifiable, Sendable {
    let id: String
    let title: String
    var items: [Item]
    var hasNextBatch: Bool
}

// MARK: - Search Results

struct SearchResults: Sendable {
    var songs: [SongItem] = []
    var albums: [AlbumItem] = []
    var artists: [ArtistItem] = []
    var playlists: [PlaylistItem] = []

    var isEmpty: Bool {
        songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty
    }
}

// MARK: - Now Playing State

struct NowPlayingState: Sendable {
    let title: String
    let artistName: String
    let artworkURL: ArtworkSource?
    let isPlaying: Bool
    let playbackTime: TimeInterval
    let duration: TimeInterval?
}
