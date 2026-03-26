import XCTest
@testable import Crate

@MainActor
final class AlbumDetailViewModelTests: XCTestCase {

    func testLoad_populatesAlbumAndTracks() async {
        let mockService = MockCatalogService()
        mockService.chartsDelay = .zero
        let vm = AlbumDetailViewModel(albumID: "album-1", catalogService: mockService)

        await vm.load()

        XCTAssertNotNil(vm.album)
        XCTAssertFalse(vm.tracks.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }

    func testLoad_setsErrorOnFailure() async {
        let mockService = MockCatalogService()
        mockService.shouldThrowError = true
        let vm = AlbumDetailViewModel(albumID: "album-1", catalogService: mockService)

        await vm.load()

        XCTAssertNotNil(vm.error)
        XCTAssertNil(vm.album)
    }

    func testMetadataString_formatsCorrectly() async {
        let mockService = MockCatalogService()
        mockService.chartsDelay = .zero
        let vm = AlbumDetailViewModel(albumID: "album-1", catalogService: mockService)

        await vm.load()

        // Should contain track count and genre
        let metadata = vm.metadataString
        XCTAssertNotNil(metadata)
        XCTAssertTrue(metadata?.contains("song") ?? false)
    }

    func testMetadataString_nilBeforeLoading() {
        let mockService = MockCatalogService()
        let vm = AlbumDetailViewModel(albumID: "album-1", catalogService: mockService)

        XCTAssertNil(vm.metadataString)
    }
}
