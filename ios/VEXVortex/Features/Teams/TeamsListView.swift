import SwiftUI

struct TeamsListView: View {
    @StateObject private var viewModel = TeamsViewModel()
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isShowingStaleData {
                    StaleDataBanner()
                }
                ForEach(viewModel.filteredTeams) { team in
                    NavigationLink(value: team) {
                        TeamRow(team: team, isFavorite: favorites.isFavorite(team.id))
                    }
                    .listRowBackground(Color.appBackground)
                }
            }
            .minimalListStyle()
            .navigationTitle("Teams")
            .searchable(text: $viewModel.searchText, prompt: "Search team number or name")
            .navigationDestination(for: Team.self) { team in
                TeamDetailView(team: team)
            }
            .overlay {
                if viewModel.isLoading && viewModel.teams.isEmpty {
                    ProgressView("Loading teams…")
                } else if viewModel.teams.isEmpty, let message = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Couldn't load teams",
                        systemImage: "wifi.slash",
                        description: Text(message)
                    )
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }
}

private struct TeamRow: View {
    let team: Team
    let isFavorite: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(team.number)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                Text(team.name)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(team.number), \(team.name)\(isFavorite ? ", favorited" : "")")
    }
}
