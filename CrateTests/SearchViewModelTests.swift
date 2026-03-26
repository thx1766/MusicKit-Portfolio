import XCTest
@testable import Crate

@MainActor
final class SearchViewModelTests: XCTestCase {

    // MARK: - Debounced Search

    func testSearch_withValidTerm_returnsResults() async {
        let mockService = MockSearchService()
        mockService.searchDelay = .zero
        let vm = SearchViewModel(searchService: mockService)

        vm.searchText = "Song"

        // Wait for debounce (300ms) + execution
        try? await Task.sleep(for: .milliseconds(500))

        XCTAssertFalse(vm.results.isEmpty)
        XCTAssertFalse(vm.results.songs.isEmpty)
    }

    func testSearch_withShortTerm_doesNotSearch() async {
        let mockService = MockSearchService()
        let vm = SearchViewModel(searchService: mockService)

        vm.searchText = "a"

        try? await Task.sleep(for: .milliseconds(500))

        XCTAssertTrue(vm.results.isEmpty)
        XCTAssertFalse(vm.isSearching)
    }

    func testSearch_debouncesConcurrentInputs() async {
        let mockService = MockSearchService()
        mockService.searchDelay = .zero
        let vm = SearchViewModel(searchService: mockService)

        // Rapid typing — only the last term should trigger a search
        vm.searchText = "So"
        vm.searchText = "Son"
        vm.searchText = "Song"

        try? await Task.sleep(for: .milliseconds(600))

        // Should have results for "Song"
        XCTAssertFalse(vm.results.isEmpty)
    }

    // MARK: - Error Handling

    func testSearch_setsErrorOnFailure() async {
        let mockService = MockSearchService()
        mockService.searchDelay = .zero
        mockService.shouldThrowError = true
        let vm = SearchViewModel(searchService: mockService)

        vm.searchText = "Song"
        try? await Task.sleep(for: .milliseconds(500))

        XCTAssertNotNil(vm.error)
    }

    // MARK: - Suggestions

    func testShowSuggestions_trueWhenSearchTextShort() {
        let mockService = MockSearchService()
        let vm = SearchViewModel(searchService: mockService)

        vm.searchText = ""
        XCTAssertTrue(vm.showSuggestions)

        vm.searchText = "a"
        XCTAssertTrue(vm.showSuggestions)
    }

    // MARK: - Recent Searches

    func testClearRecentSearches_emptiesList() {
        let mockService = MockSearchService()
        let vm = SearchViewModel(searchService: mockService)

        vm.clearRecentSearches()
        XCTAssertTrue(vm.recentSearches.isEmpty)
    }

    func testSelectSuggestion_setsSearchText() {
        let mockService = MockSearchService()
        let vm = SearchViewModel(searchService: mockService)

        vm.selectSuggestion("Pop Music")
        XCTAssertEqual(vm.searchText, "Pop Music")
    }
}
