import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    let eventCode: String?
    let name: String
    let eventType: String?
    /// Postgres `date` columns decode as plain "YYYY-MM-DD" strings — there is
    /// no time-of-day or timezone to a date-only field, so this is not a `Date`.
    let startDate: String
    let endDate: String
    let city: String?
    let region: String?
    let country: String?
    let venue: String?

    enum CodingKeys: String, CodingKey {
        case id
        case eventCode = "event_code"
        case name
        case eventType = "event_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case city, region, country, venue
    }
}
