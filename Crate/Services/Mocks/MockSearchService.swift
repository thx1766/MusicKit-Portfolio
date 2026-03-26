import Foundation

/// Mock search service for previews and unit tests.
final class MockSearchService: SearchServiceProtocol, @unchecked Sendable {

    var searchDelay: Duration = .milliseconds(300)
    var shouldThrowError = false

    func search(term: String, limit: Int) async throws -> SearchResults {
        try await Task.sleep(for: searchDelay)
        if shouldThrowError { throw MockError.simulated }

        // Filter sample data by term for realistic mock behavior
        let lowercasedTerm = term.lowercased()

        return SearchResults(
            songs: MockCatalogService.sampleSongs.filter {
                $0.title.lowercased().contains(lowercasedTerm) || lowercasedTerm.isEmpty
            },
            albums: MockCatalogService.sampleAlbums.filter {
                $0.title.lowercased().contains(lowercasedTerm) || lowercasedTerm.isEmpty
            },
            artists: MockCatalogService.sampleArtists.filter {
                $0.name.lowercased().contains(lowercasedTerm) || lowercasedTerm.isEmpty
            },
            playlists: MockCatalogService.samplePlaylists.filter {
                $0.name.lowercased().contains(lowercasedTerm) || lowercasedTerm.isEmpty
            }
        )
    }

    func searchSuggestions(term: String) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(100))
        return ["Pop Music", "Rock Classics", "Hip Hop", "Jazz Essentials", "Chill Vibes"]
            .filter { $0.lowercased().contains(term.lowercased()) || term.isEmpty }
    }
}
