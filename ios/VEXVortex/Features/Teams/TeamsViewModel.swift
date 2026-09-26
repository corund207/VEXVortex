import Foundation

@MainActor
final class TeamsViewModel: ObservableObject {
    @Published private(set) var teams: [Team] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isShowingStaleData = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""

    private let client: SupabaseClient
    private let cacheKey = "teams"

    var filteredTeams: [Team] {
        guard !searchText.isEmpty else { return teams }
        let needle = searchText.lowercased()
        return teams.filter {
            $0.number.lowercased().contains(needle) || $0.name.lowercased().contains(needle)
        }
    }

    init(client: SupabaseClient = .shared) {
        self.client = client
        if let cached = CacheStore.load([Team].self, forKey: cacheKey) {
            teams = cached.value
            isShowingStaleData = cached.isStale
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched: [Team] = try await client.fetch(
                "teams",
                query: .init(select: "*", order: "number.asc", limit: 500)
            )
            teams = fetched
            isShowingStaleData = false
            CacheStore.save(fetched, forKey: cacheKey)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            if let cached = CacheStore.load([Team].self, forKey: cacheKey) {
                teams = cached.value
                isShowingStaleData = true
            }
        }
    }
}
