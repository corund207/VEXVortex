import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var teams: [Team] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let client: SupabaseClient

    init(client: SupabaseClient = .shared) {
        self.client = client
    }

    func load(favoriteIDs: Set<UUID>) async {
        guard !favoriteIDs.isEmpty else {
            teams = []
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        let idList = favoriteIDs.map(\.uuidString).joined(separator: ",")
        do {
            teams = try await client.fetch(
                "teams",
                query: .init(select: "*", filters: ["id=in.(\(idList))"], order: "number.asc")
            )
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
