import Foundation

protocol RestaurantRepositoryProtocol {
    func getAll() async throws -> [Restaurant]
    func get(byId id: UUID) async throws -> Restaurant?
    func save(_ restaurant: Restaurant) async throws
    func update(_ restaurant: Restaurant) async throws
    func delete(_ restaurant: Restaurant) async throws
}

@MainActor
final class RestaurantRepository: RestaurantRepositoryProtocol {
    private let persistenceService: PersistenceServiceProtocol
    private let cacheManager: CacheManager
    private let key = "savedRestaurants"

    init(
        persistenceService: PersistenceServiceProtocol,
        cacheManager: CacheManager = .shared
    ) {
        self.persistenceService = persistenceService
        self.cacheManager = cacheManager
    }

    func getAll() async throws -> [Restaurant] {
        if let cached: [Restaurant] = cacheManager.get(forKey: .restaurants) {
            return cached
        }

        guard let restaurants = try persistenceService.load([Restaurant].self, forKey: key) else {
            return []
        }

        let sorted = restaurants.sortedByDate()
        cacheManager.set(sorted, forKey: .restaurants)
        return sorted
    }

    func get(byId id: UUID) async throws -> Restaurant? {
        let restaurants = try await getAll()
        return restaurants.first { $0.id == id }
    }

    func save(_ restaurant: Restaurant) async throws {
        var restaurants = try await getAll()
        restaurants.insert(restaurant, at: 0)
        try await saveAll(restaurants)
    }

    func update(_ restaurant: Restaurant) async throws {
        var restaurants = try await getAll()
        guard let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) else {
            throw GameError.restaurantNotFound(id: restaurant.id)
        }
        restaurants[index] = restaurant
        try await saveAll(restaurants)
    }

    func delete(_ restaurant: Restaurant) async throws {
        var restaurants = try await getAll()
        restaurants.removeAll { $0.id == restaurant.id }
        try await saveAll(restaurants)
    }

    private func saveAll(_ restaurants: [Restaurant]) async throws {
        let sorted = restaurants.sortedByDate()
        try persistenceService.save(sorted, forKey: key)
        cacheManager.set(sorted, forKey: .restaurants)
    }
}
