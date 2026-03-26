import XCTest

/// UI performance test measuring scroll FPS on the Browse screen.
/// Run with: Xcode → Product → Profile → Core Animation
final class ScrollPerformanceTests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    func testBrowseScrollPerformance() throws {
        // Measure scroll performance on the Browse tab
        let browseTab = app.tabBars.buttons["Browse"]
        guard browseTab.waitForExistence(timeout: 10) else {
            throw XCTSkip("Browse tab not found — may need MusicKit authorization")
        }

        browseTab.tap()

        // Wait for content to load
        let scrollView = app.scrollViews.firstMatch
        guard scrollView.waitForExistence(timeout: 10) else {
            throw XCTSkip("Scroll view not found — content may not have loaded")
        }

        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeDown(velocity: .fast)
        }
    }

    func testSearchResultsScrollPerformance() throws {
        let searchTab = app.tabBars.buttons["Search"]
        guard searchTab.waitForExistence(timeout: 10) else {
            throw XCTSkip("Search tab not found")
        }

        searchTab.tap()

        // Type a search term
        let searchField = app.searchFields.firstMatch
        guard searchField.waitForExistence(timeout: 5) else {
            throw XCTSkip("Search field not found")
        }

        searchField.tap()
        searchField.typeText("pop")

        // Wait for results
        try? Thread.sleep(forTimeInterval: 2)

        let list = app.tables.firstMatch
        guard list.waitForExistence(timeout: 5) else {
            throw XCTSkip("Results list not found")
        }

        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            list.swipeUp(velocity: .fast)
            list.swipeDown(velocity: .fast)
        }
    }
}
