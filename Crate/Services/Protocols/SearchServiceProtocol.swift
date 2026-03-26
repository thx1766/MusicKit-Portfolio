import Foundation

/// Abstracts Apple Music search for testability.
/// Live implementation wraps MusicKit's `MusicCatalogSearchRequest`.
protocol SearchServiceProtocol: Sendable {

    /// Performs a catalog search across songs, albums, artists, and playlists.
    func search(term: String, limit: Int) async throws -> SearchResults

    /// Fetches search suggestions for the given partial term.
    func searchSuggestions(term: String) async throws -> [String]
}
