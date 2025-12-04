import Foundation
import SwiftUI
import OSLog

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()

    let persistenceService: PersistenceServiceProtocol
    let playerRepository: PlayerRepositoryProtocol
    let restaurantRepository: RestaurantRepositoryProtocol
    let gameRepository: GameRepositoryProtocol
    let groupRepository: GroupRepositoryProtocol
    let dataManager: DataManager
    let router: GameRouter
    let settings: AppSettings

    private init() {
        self.persistenceService = UserDefaultsPersistenceService()
        self.playerRepository = PlayerRepository(persistenceService: persistenceService)
        self.restaurantRepository = RestaurantRepository(persistenceService: persistenceService)
        self.gameRepository = GameRepository(persistenceService: persistenceService)
        self.groupRepository = GroupRepository(persistenceService: persistenceService)
        self.dataManager = DataManager.shared
        self.router = GameRouter()
        self.settings = AppSettings.shared

        AppLogger.lifecycle.info("DependencyContainer initialized")
    }

    static func makePreview() -> DependencyContainer {
        return DependencyContainer()
    }
}

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

extension View {
    func dependencies(_ container: DependencyContainer) -> some View {
        self.environment(\.dependencies, container)
    }
}
