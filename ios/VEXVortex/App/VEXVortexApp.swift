import SwiftUI

@main
struct VEXVortexApp: App {
    @StateObject private var favorites = FavoritesStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(favorites)
        }
    }
}
