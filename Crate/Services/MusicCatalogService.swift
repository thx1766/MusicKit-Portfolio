import Foundation
import MusicKit

/// Live catalog service backed by MusicKit.
/// Maps MusicKit types to display models for view consumption.
struct MusicCatalogService: CatalogServiceProtocol {

    func fetchCharts(limit: Int) async throws -> (
        albums: ChartSection<AlbumItem>,
        playlists: ChartSection<PlaylistItem>,
        songs: ChartSection<SongItem>
    ) {
        var request = MusicCatalogChartsRequest(
            kinds: [.mostPlayed, .dailyGlobalTop],
            types: [Album.self, Playlist.self, Song.self]
        )
        request.limit = limit

        let response = try await request.response()

        let albumChart = response.albumCharts.first
        let playlistChart = response.playlistCharts.first
        let songChart = response.songCharts.first

        let albums = ChartSection<AlbumItem>(
            id: albumChart?.id ?? "albums",
            title: albumChart?.title ?? "Top Albums",
            items: albumChart?.items.map { $0.toDisplayModel() } ?? [],
            hasNextBatch: albumChart?.items.hasNextBatch ?? false
        )

        let playlists = ChartSection<PlaylistItem>(
            id: playlistChart?.id ?? "playlists",
            title: playlistChart?.title ?? "Top Playlists",
            items: playlistChart?.items.map { $0.toDisplayModel() } ?? [],
            hasNextBatch: playlistChart?.items.hasNextBatch ?? false
        )

        let songs = ChartSection<SongItem>(
            id: songChart?.id ?? "songs",
            title: songChart?.title ?? "Top Songs",
            items: songChart?.items.map { $0.toDisplayModel() } ?? [],
            hasNextBatch: songChart?.items.hasNextBatch ?? false
        )

        return (albums, playlists, songs)
    }

    func fetchNextBatch<T: Identifiable & Hashable & Sendable>(
        for section: ChartSection<T>
    ) async throws -> ChartSection<T> {
        // Pagination is handled at the MusicItemCollection level.
        // Since we map to display models, we'd need to store the original collection reference.
        // For now, return the section unchanged — pagination will be implemented with a collection cache.
        return section
    }

    func fetchAlbum(id: String) async throws -> (album: AlbumItem, tracks: [SongItem]) {
        let musicID = MusicItemID(id)
        var request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: musicID)
        request.properties = [.tracks, .artists]

        let response = try await request.response()
        guard let album = response.items.first else {
            throw CatalogError.notFound
        }

        let tracks = album.tracks?.compactMap { track -> SongItem? in
            guard case .song(let song) = track else { return nil }
            return song.toDisplayModel()
        } ?? []
        return (album.toDisplayModel(), tracks)
    }

    func fetchArtist(id: String) async throws -> (
        artist: ArtistItem,
        topSongs: [SongItem],
        albums: [AlbumItem]
    ) {
        let musicID = MusicItemID(id)
        var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: musicID)
        request.properties = [.topSongs, .albums]

        let response = try await request.response()
        guard let artist = response.items.first else {
            throw CatalogError.notFound
        }

        let topSongs = artist.topSongs?.map { $0.toDisplayModel() } ?? []
        let albums = artist.albums?.map { $0.toDisplayModel() } ?? []

        return (artist.toDisplayModel(), topSongs, albums)
    }

    func fetchPlaylist(id: String) async throws -> (playlist: PlaylistItem, tracks: [SongItem]) {
        let musicID = MusicItemID(id)
        var request = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: musicID)
        request.properties = [.tracks]

        let response = try await request.response()
        guard let playlist = response.items.first else {
            throw CatalogError.notFound
        }

        let tracks: [SongItem] = playlist.tracks?.compactMap { entry in
            switch entry {
            case .song(let song):
                return song.toDisplayModel()
            default:
                return nil
            }
        } ?? []

        return (playlist.toDisplayModel(), tracks)
    }

    func fetchRelatedAlbums(for albumID: String, limit: Int) async throws -> [AlbumItem] {
        // Fetch the album's artist, then get their other albums
        let (_, _) = try await fetchAlbum(id: albumID)
        // For a more robust implementation, we'd fetch by artist ID
        // This is simplified for the portfolio
        return []
    }
}

// MARK: - Error

enum CatalogError: LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound: return "The requested item was not found in the catalog."
        }
    }
}

// MARK: - MusicKit → Display Model Mapping

extension Album {
    func toDisplayModel() -> AlbumItem {
        AlbumItem(
            id: id.rawValue,
            title: title,
            artistName: artistName,
            artworkURL: artwork?.toArtworkSource(),
            releaseDate: releaseDate,
            trackCount: trackCount,
            genreNames: genreNames
        )
    }
}

extension Song {
    func toDisplayModel() -> SongItem {
        SongItem(
            id: id.rawValue,
            title: title,
            artistName: artistName,
            albumTitle: albumTitle,
            artworkURL: artwork?.toArtworkSource(),
            duration: duration,
            trackNumber: trackNumber
        )
    }
}

extension Artist {
    func toDisplayModel() -> ArtistItem {
        ArtistItem(
            id: id.rawValue,
            name: name,
            artworkURL: artwork?.toArtworkSource(),
            genreNames: genreNames ?? []
        )
    }
}

extension Playlist {
    func toDisplayModel() -> PlaylistItem {
        PlaylistItem(
            id: id.rawValue,
            name: name,
            curatorName: curatorName,
            description: shortDescription,
            artworkURL: artwork?.toArtworkSource(),
            trackCount: tracks?.count ?? 0
        )
    }
}

extension Artwork {
    func toArtworkSource() -> ArtworkSource {
        // MusicKit Artwork provides url(width:height:) which returns a sized URL.
        // We capture a template URL at a reference size, then replace dimensions at request time.
        let referenceURL = url(width: 1000, height: 1000)
        let template = referenceURL?.absoluteString
            .replacingOccurrences(of: "1000x1000", with: "{w}x{h}")

        return ArtworkSource(
            urlTemplate: template,
            width: maximumWidth,
            height: maximumHeight
        )
    }
}
