import SwiftUI

struct EventDetailView: View {
    let event: Event
    @StateObject private var viewModel: EventDetailViewModel

    init(event: Event) {
        self.event = event
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        List {
            Section("Event") {
                LabeledContent("Dates", value: "\(event.startDate) – \(event.endDate)")
                if let venue = event.venue {
                    LabeledContent("Venue", value: venue)
                }
                let location = [event.city, event.region, event.country].compactMap { $0 }.joined(separator: ", ")
                if !location.isEmpty {
                    LabeledContent("Location", value: location)
                }
            }

            Section("Rankings") {
                if viewModel.rankings.isEmpty {
                    Text("No rankings yet").foregroundStyle(Color.textSecondary)
                }
                ForEach(viewModel.rankings) { ranking in
                    HStack {
                        Text("#\(ranking.rank)")
                            .bold()
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 32, alignment: .leading)
                        Text(viewModel.teamLabel(ranking.teamId))
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        Text("\(ranking.wins)-\(ranking.losses)-\(ranking.ties)")
                            .foregroundStyle(Color.textSecondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Rank \(ranking.rank), \(viewModel.teamLabel(ranking.teamId)), \(ranking.wins) wins \(ranking.losses) losses \(ranking.ties) ties")
                }
            }

            Section("Matches") {
                if viewModel.matches.isEmpty {
                    Text("No matches yet").foregroundStyle(Color.textSecondary)
                }
                ForEach(viewModel.matches) { match in
                    MatchRowView(match: match, teamLabel: viewModel.teamLabel)
                }
            }
        }
        .listRowBackground(Color.appSurface)
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .navigationTitle(event.name)
        .overlay {
            if viewModel.isLoading && viewModel.matches.isEmpty && viewModel.rankings.isEmpty {
                ProgressView("Loading event…")
            } else if let message = viewModel.errorMessage,
                      viewModel.matches.isEmpty, viewModel.rankings.isEmpty {
                ContentUnavailableView("Couldn't load event data", systemImage: "wifi.slash", description: Text(message))
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
