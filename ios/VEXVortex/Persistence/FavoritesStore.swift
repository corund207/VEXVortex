import Foundation

/// On-device favorites. Local-first by design (see root README) — favorites
/// don't sync across devices until/unless Supabase Auth lands.
@MainActor
final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    @Published private(set) var favoriteTeamIDs: Set<UUID>

    private let defaults: UserDefaults
    private let storageKey = "favoriteTeamIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.stringArray(forKey: storageKey) ?? []
        self.favoriteTeamIDs = Set(stored.compactMap(UUID.init))
    }

    func isFavorite(_ teamID: UUID) -> Bool {
        favoriteTeamIDs.contains(teamID)
    }

    func toggle(_ teamID: UUID) {
        if favoriteTeamIDs.contains(teamID) {
            favoriteTeamIDs.remove(teamID)
        } else {
            favoriteTeamIDs.insert(teamID)
        }
        defaults.set(favoriteTeamIDs.map(\.uuidString), forKey: storageKey)
    }
}
