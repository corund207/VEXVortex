import SwiftUI

struct StaleDataBanner: View {
    var body: some View {
        Label("Showing cached data — pull to refresh", systemImage: "clock.arrow.circlepath")
            .font(.footnote)
            .foregroundStyle(Color.textSecondary)
            .listRowBackground(Color.appBackground)
            .accessibilityLabel("Showing cached data. Pull to refresh for the latest.")
    }
}
