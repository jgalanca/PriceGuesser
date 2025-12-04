import SwiftUI
import OSLog

@MainActor
@Observable
final class HomeViewModel {
    private let playerRepository: PlayerRepositoryProtocol
    private let gameRepository: GameRepositoryProtocol
    private let router: GameRouter

    var showSettings = false
    var isLoading = false
    var errorMessage: String?

    init(
        playerRepository: PlayerRepositoryProtocol,
        gameRepository: GameRepositoryProtocol,
        router: GameRouter
    ) {
        self.playerRepository = playerRepository
        self.gameRepository = gameRepository
        self.router = router
    }

    func onAppear() async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await playerRepository.getAll()
            _ = try await gameRepository.getAll()
            AppLogger.ui.info("HomeView data loaded")
        } catch {
            errorMessage = error.localizedDescription
            AppLogger.error.logError("Failed to load home data", error: error)
        }
    }

    func startGame() {
        router.navigate(to: .setup)
    }

    func showTutorial() {
        router.navigate(to: .tutorial)
    }

    func showHistory() {
        router.navigate(to: .history)
    }

    func showRanking() {
        router.navigate(to: .ranking)
    }

    func openSettings() {
        showSettings = true
    }
}
