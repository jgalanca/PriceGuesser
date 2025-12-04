import Foundation

protocol GameRepositoryProtocol {
    func getAll() async throws -> [Game]
    func get(byId id: UUID) async throws -> Game?
    func save(_ game: Game) async throws
    func delete(_ game: Game) async throws
    func getGames(forPlayer playerId: UUID) async throws -> [Game]
    func getGames(forRestaurant restaurantId: UUID) async throws -> [Game]
}

@MainActor
final class GameRepository: GameRepositoryProtocol {
    private let persistenceService: PersistenceServiceProtocol
    private let cacheManager: CacheManager
    private let key = "gameHistory"

    init(
        persistenceService: PersistenceServiceProtocol,
        cacheManager: CacheManager = .shared
    ) {
        self.persistenceService = persistenceService
        self.cacheManager = cacheManager
    }

    func getAll() async throws -> [Game] {
        if let cached: [Game] = cacheManager.get(forKey: .gameHistory) {
            return cached
        }

        guard let games = try persistenceService.load([Game].self, forKey: key) else {
            return []
        }

        let sorted = games.sortedByDate()
        cacheManager.set(sorted, forKey: .gameHistory)
        return sorted
    }

    func get(byId id: UUID) async throws -> Game? {
        let games = try await getAll()
        return games.first { $0.id == id }
    }

    func save(_ game: Game) async throws {
        var games = try await getAll()
        games.insert(game, at: 0)
        try await saveAll(games)
    }

    func delete(_ game: Game) async throws {
        var games = try await getAll()
        games.removeAll { $0.id == game.id }
        try await saveAll(games)
    }

    func getGames(forPlayer playerId: UUID) async throws -> [Game] {
        let games = try await getAll()
        return games.filteredByPlayer(playerId)
    }

    func getGames(forRestaurant restaurantId: UUID) async throws -> [Game] {
        let games = try await getAll()
        return games.filteredByRestaurant(restaurantId)
    }

    private func saveAll(_ games: [Game]) async throws {
        let sorted = games.sortedByDate()
        try persistenceService.save(sorted, forKey: key)
        cacheManager.set(sorted, forKey: .gameHistory)
    }
}
