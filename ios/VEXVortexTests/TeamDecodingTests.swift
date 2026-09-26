import XCTest
@testable import VEXVortex

final class TeamDecodingTests: XCTestCase {
    func testDecodesSnakeCaseFields() throws {
        let json = """
        {
            "id": "5A5A5A5A-5A5A-5A5A-5A5A-5A5A5A5A5A5A",
            "number": "90000A",
            "name": "Vortex Robotics",
            "organization": "Example Middle School",
            "city": "Springfield",
            "region": "CA",
            "country": "USA",
            "program": "VRC",
            "grade_level": "Middle School",
            "robot_name": "Maelstrom"
        }
        """.data(using: .utf8)!

        let team = try JSONDecoder().decode(Team.self, from: json)

        XCTAssertEqual(team.number, "90000A")
        XCTAssertEqual(team.organization, "Example Middle School")
        XCTAssertEqual(team.gradeLevel, "Middle School")
        XCTAssertEqual(team.robotName, "Maelstrom")
    }

    func testDecodesWithMissingOptionalFields() throws {
        let json = """
        {
            "id": "5A5A5A5A-5A5A-5A5A-5A5A-5A5A5A5A5A5A",
            "number": "12345X",
            "name": "Iron Falcons",
            "organization": null,
            "city": null,
            "region": null,
            "country": null,
            "program": "VRC",
            "grade_level": null,
            "robot_name": null
        }
        """.data(using: .utf8)!

        let team = try JSONDecoder().decode(Team.self, from: json)

        XCTAssertNil(team.organization)
        XCTAssertNil(team.robotName)
    }
}
