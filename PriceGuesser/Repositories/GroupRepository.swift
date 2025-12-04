import Foundation

protocol GroupRepositoryProtocol {
    func getAll() async throws -> [Group]
    func get(byId id: UUID) async throws -> Group?
    func save(_ group: Group) async throws
    func update(_ group: Group) async throws
    func delete(_ group: Group) async throws
}

@MainActor
final class GroupRepository: GroupRepositoryProtocol {
    private let persistenceService: PersistenceServiceProtocol
    private let cacheManager: CacheManager
    private let key = "savedGroups"

    init(
        persistenceService: PersistenceServiceProtocol,
        cacheManager: CacheManager = .shared
    ) {
        self.persistenceService = persistenceService
        self.cacheManager = cacheManager
    }

    func getAll() async throws -> [Group] {
        if let cached: [Group] = cacheManager.get(forKey: .groups) {
            return cached
        }

        guard let groups = try persistenceService.load([Group].self, forKey: key) else {
            return []
        }

        let sorted = groups.sortedByName()
        cacheManager.set(sorted, forKey: .groups)
        return sorted
    }

    func get(byId id: UUID) async throws -> Group? {
        let groups = try await getAll()
        return groups.first { $0.id == id }
    }

    func save(_ group: Group) async throws {
        var groups = try await getAll()
        groups.append(group)
        try await saveAll(groups)
    }

    func update(_ group: Group) async throws {
        var groups = try await getAll()
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else {
            throw GameError.groupNotFound(id: group.id)
        }
        groups[index] = group
        try await saveAll(groups)
    }

    func delete(_ group: Group) async throws {
        var groups = try await getAll()
        groups.removeAll { $0.id == group.id }
        try await saveAll(groups)
    }

    private func saveAll(_ groups: [Group]) async throws {
        let sorted = groups.sortedByName()
        try persistenceService.save(sorted, forKey: key)
        cacheManager.set(sorted, forKey: .groups)
    }
}
