import SwiftUI

struct TeamDetailView: View {
    let team: Team
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        List {
            Section("Team") {
                LabeledContent("Number", value: team.number)
                LabeledContent("Name", value: team.name)
                if let organization = team.organization {
                    LabeledContent("Organization", value: organization)
                }
                if let robotName = team.robotName {
                    LabeledContent("Robot", value: robotName)
                }
                LabeledContent("Program", value: team.program)
            }
            Section("Location") {
                LabeledContent("City", value: team.city ?? "—")
                LabeledContent("Region", value: team.region ?? "—")
                LabeledContent("Country", value: team.country ?? "—")
            }
        }
        .listRowBackground(Color.appSurface)
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .navigationTitle(team.number)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                let favorited = favorites.isFavorite(team.id)
                Button {
                    favorites.toggle(team.id)
                } label: {
                    Image(systemName: favorited ? "star.fill" : "star")
                }
                .accessibilityLabel(favorited ? "Remove from favorites" : "Add to favorites")
            }
        }
    }
}
