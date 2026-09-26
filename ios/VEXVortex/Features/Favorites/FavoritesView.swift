import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesStore
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if favorites.favoriteTeamIDs.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "star",
                        description: Text("Star a team to track it here.")
                    )
                } else {
                    List(viewModel.teams) { team in
                        NavigationLink(value: team) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(team.number).font(.headline).foregroundStyle(Color.textPrimary)
                                Text(team.name).font(.subheadline).foregroundStyle(Color.textSecondary)
                            }
                        }
                        .listRowBackground(Color.appBackground)
                    }
                    .minimalListStyle()
                    .overlay {
                        if viewModel.isLoading && viewModel.teams.isEmpty {
                            ProgressView("Loading favorites…")
                        } else if viewModel.teams.isEmpty, let message = viewModel.errorMessage {
                            ContentUnavailableView("Couldn't load favorites", systemImage: "wifi.slash", description: Text(message))
                        }
                    }
                    .navigationDestination(for: Team.self) { team in
                        TeamDetailView(team: team)
                    }
                }
            }
            .navigationTitle("Favorites")
            .task(id: favorites.favoriteTeamIDs) {
                await viewModel.load(favoriteIDs: favorites.favoriteTeamIDs)
            }
        }
    }
}
