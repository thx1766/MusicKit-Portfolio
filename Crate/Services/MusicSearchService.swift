import Foundation
import MusicKit

/// Live search service backed by MusicKit.
struct MusicSearchService: SearchServiceProtocol {

    func search(term: String, limit: Int) async throws -> SearchResults {
        var request = MusicCatalogSearchRequest(term: term, types: [
            Song.self,
            Album.self,
            Artist.self,
            Playlist.self
        ])
        request.limit = limit

        let response = try await request.response()

        return SearchResults(
            songs: response.songs.map { $0.toDisplayModel() },
            albums: response.albums.map { $0.toDisplayModel() },
            artists: response.artists.map { $0.toDisplayModel() },
            playlists: response.playlists.map { $0.toDisplayModel() }
        )
    }

    func searchSuggestions(term: String) async throws -> [String] {
        let request = MusicCatalogSearchSuggestionsRequest(term: term, includingTopResultsOfTypes: [
            Song.self,
            Album.self,
            Artist.self
        ])

        let response = try await request.response()
        return response.suggestions.compactMap { suggestion in
            suggestion.displayTerm
        }
    }
}
