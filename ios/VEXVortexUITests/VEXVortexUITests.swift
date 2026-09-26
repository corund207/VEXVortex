import XCTest

final class VEXVortexUITests: XCTestCase {
    func testAppLaunchesToTabBar() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
}
