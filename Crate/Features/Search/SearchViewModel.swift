import Foundation
import Combine

/// View model for the Search screen.
/// Implements debounced search with categorized results and suggestions.
@Observable
final class SearchViewModel {
    private let searchService: any SearchServiceProtocol
    private var searchTask: Task<Void, Never>?

    var searchText = "" {
        didSet { debouncedSearch() }
    }

    var results = SearchResults()
    var suggestions: [String] = []
    var recentSearches: [String] = []
    var isSearching = false
    var error: Error?

    /// Whether to show suggestions vs results
    var showSuggestions: Bool {
        searchText.count < 2 || results.isEmpty && !isSearching
    }

    init(searchService: any SearchServiceProtocol) {
        self.searchService = searchService
        loadRecentSearches()
    }

    // MARK: - Debounced Search

    private func debouncedSearch() {
        searchTask?.cancel()

        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard term.count >= 2 else {
            results = SearchResults()
            isSearching = false
            loadSuggestions(for: term)
            return
        }

        searchTask = Task { @MainActor in
            // 300ms debounce
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            await performSearch(term: term)
        }
    }

    @MainActor
    private func performSearch(term: String) async {
        isSearching = true
        error = nil

        do {
            results = try await searchService.search(term: term, limit: 25)
            saveRecentSearch(term)
        } catch {
            if !Task.isCancelled {
                self.error = error
            }
        }

        isSearching = false
    }

    // MARK: - Suggestions

    private func loadSuggestions(for term: String) {
        Task { @MainActor in
            if term.isEmpty {
                suggestions = []
                return
            }
            do {
                suggestions = try await searchService.searchSuggestions(term: term)
            } catch {
                suggestions = []
            }
        }
    }

    func selectSuggestion(_ suggestion: String) {
        searchText = suggestion
    }

    // MARK: - Recent Searches

    private static let recentSearchesKey = "CrateRecentSearches"
    private static let maxRecentSearches = 10

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(
            forKey: Self.recentSearchesKey
        ) ?? []
    }

    private func saveRecentSearch(_ term: String) {
        var recents = recentSearches
        recents.removeAll { $0.lowercased() == term.lowercased() }
        recents.insert(term, at: 0)
        recents = Array(recents.prefix(Self.maxRecentSearches))
        recentSearches = recents
        UserDefaults.standard.set(recents, forKey: Self.recentSearchesKey)
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: Self.recentSearchesKey)
    }
}
