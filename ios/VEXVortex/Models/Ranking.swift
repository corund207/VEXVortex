import Foundation

struct Ranking: Identifiable, Codable, Hashable {
    var id: String { "\(eventId)-\(teamId)" }

    let eventId: UUID
    let teamId: UUID
    let rank: Int
    let wins: Int
    let losses: Int
    let ties: Int
    let wp: Int
    let ap: Int
    let sp: Int
    let averagePoints: Double?

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case teamId = "team_id"
        case rank, wins, losses, ties, wp, ap, sp
        case averagePoints = "average_points"
    }
}

/// Wraps a PostgREST embed response shape: `event_teams?select=teams(*)`.
struct EventTeamEmbed: Codable {
    let teams: Team
}
