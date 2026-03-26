import XCTest
@testable import Crate

@MainActor
final class BrowseViewModelTests: XCTestCase {

    // MARK: - Happy Path

    func testLoadCharts_setsAlbumsPlaylistsSongs() async {
        let mockService = MockCatalogService()
        mockService.chartsDelay = .zero
        let vm = BrowseViewModel(catalogService: mockService)

        await vm.loadCharts()

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
        XCTAssertNotNil(vm.albumSection)
        XCTAssertNotNil(vm.playlistSection)
        XCTAssertNotNil(vm.songSection)
        XCTAssertEqual(vm.albumSection?.items.count, 10)
        XCTAssertEqual(vm.playlistSection?.items.count, 8)
        XCTAssertEqual(vm.songSection?.items.count, 15)
    }

    func testLoadCharts_isLoadingTransitions() async {
        let mockService = MockCatalogService()
        mockService.chartsDelay = .milliseconds(100)
        let vm = BrowseViewModel(catalogService: mockService)

        XCTAssertFalse(vm.isLoading)

        // Start loading — check immediate state
        let task = Task { await vm.loadCharts() }
        // Give the task a moment to start
        try? await Task.sleep(for: .milliseconds(10))
        XCTAssertTrue(vm.isLoading)

        await task.value
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Error Handling

    func testLoadCharts_setsErrorOnFailure() async {
        let mockService = MockCatalogService()
        mockService.chartsDelay = .zero
        mockService.shouldThrowError = true
        let vm = BrowseViewModel(catalogService: mockService)

        await vm.loadCharts()

        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.error)
        XCTAssertNil(vm.albumSection)
    }

    // MARK: - Hero Items

    func testHeroItems_derivedFromPlaylistsAndAlbums() async {
        let mockService = MockCatalogService()
        mockService.chartsDelay = .zero
        let vm = BrowseViewModel(catalogService: mockService)

        await vm.loadCharts()

        let heroItems = vm.heroItems
        XCTAssertFalse(heroItems.isEmpty)
        XCTAssertLessThanOrEqual(heroItems.count, 6)
    }

    func testHeroItems_emptyBeforeLoading() {
        let mockService = MockCatalogService()
        let vm = BrowseViewModel(catalogService: mockService)

        XCTAssertTrue(vm.heroItems.isEmpty)
    }

    // MARK: - Refresh

    func testRefresh_reloadsCharts() async {
        let mockService = MockCatalogService()
        mockService.chartsDelay = .zero
        let vm = BrowseViewModel(catalogService: mockService)

        await vm.refresh()

        XCTAssertNotNil(vm.albumSection)
        XCTAssertFalse(vm.isLoading)
    }
}
