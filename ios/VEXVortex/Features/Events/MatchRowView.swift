import SwiftUI

struct MatchRowView: View {
    let match: Match
    let teamLabel: (UUID?) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(match.round?.capitalized ?? "Match") \(match.matchNumber)")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            HStack {
                // Red/blue here are VEX alliance colors (game data), not brand
                // styling — kept as system red/blue rather than the app accent.
                allianceLabel(color: .red, team1: match.red1TeamId, team2: match.red2TeamId, score: match.redScore)
                Spacer()
                Text("vs").foregroundStyle(Color.textSecondary)
                Spacer()
                allianceLabel(color: .blue, team1: match.blue1TeamId, team2: match.blue2TeamId, score: match.blueScore)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func allianceLabel(color: Color, team1: UUID?, team2: UUID?, score: Int?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(teamLabel(team1)) & \(teamLabel(team2))")
                .foregroundStyle(color)
                .font(.subheadline)
            if let score {
                Text("\(score)")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
            }
        }
    }
}
