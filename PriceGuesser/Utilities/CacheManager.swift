import Foundation
import OSLog

enum CacheKey: String {
    case players
    case restaurants
    case gameHistory
    case groups
    case lastSync
}

@MainActor
final class CacheManager {
    static let shared = CacheManager()

    private var cache: [String: Any] = [:]
    private let cacheQueue = DispatchQueue(label: "com.priceguesser.cache", qos: .userInitiated)

    private init() {}

    func set<T>(_ value: T, forKey key: CacheKey) {
        cache[key.rawValue] = value
    }

    func get<T>(forKey key: CacheKey) -> T? {
        return cache[key.rawValue] as? T
    }

    func remove(forKey key: CacheKey) {
        cache.removeValue(forKey: key.rawValue)
    }

    func clearAll() {
        cache.removeAll()
        AppLogger.data.info("Cache cleared")
    }
}
