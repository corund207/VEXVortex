import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TeamsListView()
                .tabItem { Label("Teams", systemImage: "person.3") }

            EventsListView()
                .tabItem { Label("Events", systemImage: "calendar") }

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "star") }
        }
        .tint(Color.accentColor)
        .toolbarBackground(Color.appSurface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    RootView()
        .environmentObject(FavoritesStore.shared)
}
