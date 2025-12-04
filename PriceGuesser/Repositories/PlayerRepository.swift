import Foundation
import OSLog

protocol PlayerRepositoryProtocol {
    func getAll() async throws -> [Player]
    func get(byId id: UUID) async throws -> Player?
    func save(_ player: Player) async throws
    func update(_ player: Player) async throws
    func delete(_ player: Player) async throws
}

@MainActor
final class PlayerRepository: PlayerRepositoryProtocol {
    private let persistenceService: PersistenceServiceProtocol
    private let cacheManager: CacheManager
    private let key = "savedPlayers"

    init(
        persistenceService: PersistenceServiceProtocol,
        cacheManager: CacheManager = .shared
    ) {
        self.persistenceService = persistenceService
        self.cacheManager = cacheManager
    }

    func getAll() async throws -> [Player] {
        if let cached: [Player] = cacheManager.get(forKey: .players) {
            AppLogger.data.info("✅ Loaded players from cache")
            return cached
        }

        guard let players = try persistenceService.load([Player].self, forKey: key) else {
            return []
        }

        let sorted = players.sortedByName()
        cacheManager.set(sorted, forKey: .players)
        return sorted
    }

    func get(byId id: UUID) async throws -> Player? {
        let players = try await getAll()
        return players.first { $0.id == id }
    }

    func save(_ player: Player) async throws {
        var players = try await getAll()
        players.append(player)
        try await saveAll(players)
    }

    func update(_ player: Player) async throws {
        var players = try await getAll()
        guard let index = players.firstIndex(where: { $0.id == player.id }) else {
            throw GameError.playerNotFound(id: player.id)
        }
        players[index] = player
        try await saveAll(players)
    }

    func delete(_ player: Player) async throws {
        var players = try await getAll()
        players.removeAll { $0.id == player.id }
        try await saveAll(players)
    }

    private func saveAll(_ players: [Player]) async throws {
        let sorted = players.sortedByName()
        try persistenceService.save(sorted, forKey: key)
        cacheManager.set(sorted, forKey: .players)
        AppLogger.data.info("✅ Saved \(sorted.count) players")
    }
}
