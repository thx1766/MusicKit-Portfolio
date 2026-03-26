import Foundation

/// View model for the Album Detail screen.
@Observable
final class AlbumDetailViewModel {
    private let catalogService: any CatalogServiceProtocol
    private let albumID: String

    var album: AlbumItem?
    var tracks: [SongItem] = []
    var relatedAlbums: [AlbumItem] = []
    var isLoading = false
    var error: Error?

    init(albumID: String, catalogService: any CatalogServiceProtocol) {
        self.albumID = albumID
        self.catalogService = catalogService
    }

    @MainActor
    func load() async {
        isLoading = true
        error = nil

        do {
            let result = try await catalogService.fetchAlbum(id: albumID)
            album = result.album
            tracks = result.tracks

            // Load related albums in parallel
            relatedAlbums = try await catalogService.fetchRelatedAlbums(
                for: albumID, limit: 10
            )
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Metadata string for display (e.g., "2022 · 13 songs · Pop")
    var metadataString: String? {
        guard let album else { return nil }
        var parts: [String] = []

        if let date = album.releaseDate {
            let year = Calendar.current.component(.year, from: date)
            parts.append("\(year)")
        }

        if album.trackCount > 0 {
            parts.append("\(album.trackCount) song\(album.trackCount == 1 ? "" : "s")")
        }

        if let genre = album.genreNames.first {
            parts.append(genre)
        }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
