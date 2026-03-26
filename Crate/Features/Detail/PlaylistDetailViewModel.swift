import Foundation

/// View model for the Playlist Detail screen.
@Observable
final class PlaylistDetailViewModel {
    private let catalogService: any CatalogServiceProtocol
    private let playlistID: String

    var playlist: PlaylistItem?
    var tracks: [SongItem] = []
    var isLoading = false
    var error: Error?

    init(playlistID: String, catalogService: any CatalogServiceProtocol) {
        self.playlistID = playlistID
        self.catalogService = catalogService
    }

    @MainActor
    func load() async {
        isLoading = true
        error = nil

        do {
            let result = try await catalogService.fetchPlaylist(id: playlistID)
            playlist = result.playlist
            tracks = result.tracks
        } catch {
            self.error = error
        }

        isLoading = false
    }

    var metadataString: String? {
        guard let playlist else { return nil }
        var parts: [String] = []
        if let curator = playlist.curatorName { parts.append(curator) }
        if playlist.trackCount > 0 {
            parts.append("\(playlist.trackCount) song\(playlist.trackCount == 1 ? "" : "s")")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
