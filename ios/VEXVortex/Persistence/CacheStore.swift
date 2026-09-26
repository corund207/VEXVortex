import Foundation

/// Disk-backed cache for read-mostly Supabase resources, tagged with the
/// fetch time so views can show an explicit stale-data indicator instead of
/// silently presenting old numbers as current (see root README's "no fake
/// data" rule).
struct CachedResource<T: Codable>: Codable {
    let value: T
    let fetchedAt: Date

    var isStale: Bool {
        Date().timeIntervalSince(fetchedAt) > CacheStore.staleAfter
    }
}

enum CacheStore {
    static let staleAfter: TimeInterval = 15 * 60

    static func save<T: Codable>(_ value: T, forKey key: String) {
        let wrapped = CachedResource(value: value, fetchedAt: Date())
        guard let data = try? JSONEncoder().encode(wrapped) else { return }
        try? data.write(to: fileURL(for: key), options: .atomic)
    }

    static func load<T: Codable>(_ type: T.Type, forKey key: String) -> CachedResource<T>? {
        guard let data = try? Data(contentsOf: fileURL(for: key)) else { return nil }
        return try? JSONDecoder().decode(CachedResource<T>.self, from: data)
    }

    private static var directory: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("VEXVortexCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func fileURL(for key: String) -> URL {
        directory.appendingPathComponent("\(key).json")
    }
}
