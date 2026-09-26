import Foundation

struct Team: Identifiable, Codable, Hashable {
    let id: UUID
    let number: String
    let name: String
    let organization: String?
    let city: String?
    let region: String?
    let country: String?
    let program: String
    let gradeLevel: String?
    let robotName: String?

    enum CodingKeys: String, CodingKey {
        case id, number, name, organization, city, region, country, program
        case gradeLevel = "grade_level"
        case robotName = "robot_name"
    }
}
