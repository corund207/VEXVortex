import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case http(status: Int, body: String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .transport(let error):
            return "Network error: \(error.localizedDescription)"
        case .http(let status, _):
            return "Server returned an error (status \(status))."
        case .decoding(let error):
            return "Failed to read the server response: \(error.localizedDescription)"
        }
    }
}
