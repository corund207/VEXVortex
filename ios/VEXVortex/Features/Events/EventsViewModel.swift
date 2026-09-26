import Foundation

@MainActor
final class EventsViewModel: ObservableObject {
    @Published private(set) var events: [Event] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isShowingStaleData = false
    @Published var errorMessage: String?

    private let client: SupabaseClient
    private let cacheKey = "events"

    init(client: SupabaseClient = .shared) {
        self.client = client
        if let cached = CacheStore.load([Event].self, forKey: cacheKey) {
            events = cached.value
            isShowingStaleData = cached.isStale
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched: [Event] = try await client.fetch(
                "events",
                query: .init(select: "*", order: "start_date.desc", limit: 200)
            )
            events = fetched
            isShowingStaleData = false
            CacheStore.save(fetched, forKey: cacheKey)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            if let cached = CacheStore.load([Event].self, forKey: cacheKey) {
                events = cached.value
                isShowingStaleData = true
            }
        }
    }
}
