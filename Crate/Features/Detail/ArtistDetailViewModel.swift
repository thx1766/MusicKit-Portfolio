import Foundation

/// View model for the Artist Detail screen.
@Observable
final class ArtistDetailViewModel {
    private let catalogService: any CatalogServiceProtocol
    private let artistID: String

    var artist: ArtistItem?
    var topSongs: [SongItem] = []
    var albums: [AlbumItem] = []
    var isLoading = false
    var error: Error?

    init(artistID: String, catalogService: any CatalogServiceProtocol) {
        self.artistID = artistID
        self.catalogService = catalogService
    }

    @MainActor
    func load() async {
        isLoading = true
        error = nil

        do {
            let result = try await catalogService.fetchArtist(id: artistID)
            artist = result.artist
            topSongs = result.topSongs
            albums = result.albums
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
