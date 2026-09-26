import SwiftUI

struct EventsListView: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isShowingStaleData {
                    StaleDataBanner()
                }
                ForEach(viewModel.events) { event in
                    NavigationLink(value: event) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.name)
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)
                            Text("\(event.startDate) · \(event.city ?? "TBD")")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .listRowBackground(Color.appBackground)
                }
            }
            .minimalListStyle()
            .navigationTitle("Events")
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event)
            }
            .overlay {
                if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView("Loading events…")
                } else if viewModel.events.isEmpty, let message = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Couldn't load events",
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
