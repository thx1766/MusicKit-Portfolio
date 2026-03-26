import XCTest
@testable import Crate

final class ImageCacheTests: XCTestCase {

    // MARK: - Cache Miss

    func testImage_withNilSource_returnsNil() async {
        let cache = ArtworkImageCache()
        let image = await cache.image(for: nil, width: 100, height: 100)
        XCTAssertNil(image)
    }

    func testCachedImage_withNilSource_returnsNil() {
        let cache = ArtworkImageCache()
        let image = cache.cachedImage(for: nil, width: 100, height: 100)
        XCTAssertNil(image)
    }

    // MARK: - Cache with Invalid URL

    func testImage_withInvalidURL_returnsNil() async {
        let source = ArtworkSource(
            urlTemplate: "not-a-valid-url",
            backgroundColor: nil,
            width: 100,
            height: 100
        )
        let cache = ArtworkImageCache()
        let image = await cache.image(for: source, width: 100, height: 100)
        XCTAssertNil(image)
    }

    // MARK: - Clear Cache

    func testClearCache_doesNotCrash() {
        let cache = ArtworkImageCache()
        cache.clearCache()
        // Just verifying no crash
    }

    // MARK: - ArtworkSource URL Generation

    func testArtworkSource_generatesCorrectURL() {
        let source = ArtworkSource(
            urlTemplate: "https://example.com/art/{w}x{h}bb.jpg",
            backgroundColor: nil,
            width: 1000,
            height: 1000
        )

        let url = source.url(width: 300, height: 300)
        XCTAssertEqual(url?.absoluteString, "https://example.com/art/300x300bb.jpg")
    }

    func testArtworkSource_nilTemplate_returnsNilURL() {
        let source = ArtworkSource(
            urlTemplate: nil,
            backgroundColor: nil,
            width: nil,
            height: nil
        )

        let url = source.url(width: 300, height: 300)
        XCTAssertNil(url)
    }
}
