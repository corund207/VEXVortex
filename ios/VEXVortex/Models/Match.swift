import Foundation

enum MatchStatus: String, Codable {
    case scheduled
    case inProgress = "in_progress"
    case final = "final"
}

struct Match: Identifiable, Codable, Hashable {
    let id: UUID
    let eventId: UUID
    let division: String?
    let round: String?
    let matchNumber: Int
    let scheduledAt: Date?
    let red1TeamId: UUID?
    let red2TeamId: UUID?
    let blue1TeamId: UUID?
    let blue2TeamId: UUID?
    let redScore: Int?
    let blueScore: Int?
    let status: MatchStatus

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case division, round
        case matchNumber = "match_number"
        case scheduledAt = "scheduled_at"
        case red1TeamId = "red1_team_id"
        case red2TeamId = "red2_team_id"
        case blue1TeamId = "blue1_team_id"
        case blue2TeamId = "blue2_team_id"
        case redScore = "red_score"
        case blueScore = "blue_score"
        case status
    }
}
