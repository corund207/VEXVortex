import Foundation

@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published private(set) var matches: [Match] = []
    @Published private(set) var rankings: [Ranking] = []
    @Published private(set) var teamsByID: [UUID: Team] = [:]
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let event: Event
    private let client: SupabaseClient

    init(event: Event, client: SupabaseClient = .shared) {
        self.event = event
        self.client = client
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        let eventFilter = "event_id=eq.\(event.id.uuidString)"
        do {
            async let teamEmbeds: [EventTeamEmbed] = client.fetch(
                "event_teams",
                query: .init(select: "teams(*)", filters: [eventFilter])
            )
            async let fetchedMatches: [Match] = client.fetch(
                "matches",
                query: .init(select: "*", filters: [eventFilter], order: "match_number.asc")
            )
            async let fetchedRankings: [Ranking] = client.fetch(
                "rankings",
                query: .init(select: "*", filters: [eventFilter], order: "rank.asc")
            )

            let (teams, matchesResult, rankingsResult) = try await (teamEmbeds, fetchedMatches, fetchedRankings)
            teamsByID = Dictionary(uniqueKeysWithValues: teams.map { ($0.teams.id, $0.teams) })
            matches = matchesResult
            rankings = rankingsResult
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func teamLabel(_ id: UUID?) -> String {
        guard let id, let team = teamsByID[id] else { return "—" }
        return team.number
    }
}
