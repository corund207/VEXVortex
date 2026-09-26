import Foundation

/// Minimal read-only PostgREST client for the `vex` schema.
///
/// Only the `anon` key is ever used here — enforced RLS on the server is the
/// real security boundary (see supabase/migrations). This client has no
/// write methods on purpose: all writes happen server-side via
/// supabase/functions/sync-events, never from the app.
final class SupabaseClient {
    static let shared = SupabaseClient(config: .current)

    struct Query {
        var select: String? = nil
        /// Raw PostgREST filter expressions, e.g. `"event_id=eq.\(id)"`.
        var filters: [String] = []
        var order: String? = nil
        var limit: Int? = nil
    }

    private let config: AppConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    init(config: AppConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session

        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = formatter.date(from: string) ?? fallbackFormatter.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected an ISO 8601 date, got \(string)"
            )
        }
        self.decoder = decoder
    }

    func fetch<T: Decodable>(_ table: String, query: Query = Query()) async throws -> [T] {
        guard var components = URLComponents(
            url: config.supabaseURL.appendingPathComponent("rest/v1/\(table)"),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }

        var items: [URLQueryItem] = []
        if let select = query.select {
            items.append(URLQueryItem(name: "select", value: select))
        }
        if let order = query.order {
            items.append(URLQueryItem(name: "order", value: order))
        }
        if let limit = query.limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        for filter in query.filters {
            guard let separatorIndex = filter.firstIndex(of: "=") else { continue }
            let name = String(filter[filter.startIndex..<separatorIndex])
            let value = String(filter[filter.index(after: separatorIndex)...])
            items.append(URLQueryItem(name: name, value: value))
        }
        components.queryItems = items.isEmpty ? nil : items

        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("vex", forHTTPHeaderField: "Accept-Profile")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.transport(URLError(.badServerResponse))
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(status: http.statusCode, body: String(data: data, encoding: .utf8) ?? "")
        }

        do {
            return try decoder.decode([T].self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
