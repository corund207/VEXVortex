import XCTest
@testable import VEXVortex

@MainActor
final class FavoritesStoreTests: XCTestCase {
    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "FavoritesStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    func testToggleAddsAndRemoves() {
        let store = FavoritesStore(defaults: makeIsolatedDefaults())
        let teamID = UUID()

        XCTAssertFalse(store.isFavorite(teamID))

        store.toggle(teamID)
        XCTAssertTrue(store.isFavorite(teamID))

        store.toggle(teamID)
        XCTAssertFalse(store.isFavorite(teamID))
    }

    func testFavoritesPersistAcrossInstances() {
        let defaults = makeIsolatedDefaults()
        let teamID = UUID()

        FavoritesStore(defaults: defaults).toggle(teamID)

        let reloaded = FavoritesStore(defaults: defaults)
        XCTAssertTrue(reloaded.isFavorite(teamID))
    }
}
