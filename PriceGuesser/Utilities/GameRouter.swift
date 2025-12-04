import SwiftUI
import OSLog

// MARK: - Game Routes
enum GameRoute: Hashable {
    case setup
    case gameplay(restaurant: Restaurant, players: [Player], currency: Currency, gameMode: GameMode)
    case realPrice(restaurant: Restaurant, guesses: [PlayerGuess], currency: Currency, gameMode: GameMode)
    case results(restaurant: Restaurant, actualPrice: Double, results: [GameResult], currency: Currency, gameMode: GameMode)
    case history
    case tutorial
    case ranking
}

// MARK: - Sheet Destination
enum SheetDestination: Identifiable {
    case guessInput(player: Player, onSubmit: (Double) -> Void)

    var id: String {
        switch self {
        case .guessInput(let player, _):
            return "guessInput_\(player.id.uuidString)"
        }
    }

    static func == (lhs: SheetDestination, rhs: SheetDestination) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
@Observable
class GameRouter {
    var path = NavigationPath()
    var presentedSheet: SheetDestination?
    private(set) var routeHistory: [String] = []

    func navigate(to route: GameRoute) {
        let routeName = routeDescription(for: route)
        AppLogger.ui.logNavigation(from: routeHistory.last ?? "Root", to: routeName)
        routeHistory.append(routeName)
        path.append(route)
    }

    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
        AppLogger.ui.info("Presenting sheet: \(sheet.id)")
    }

    func dismissSheet() {
        presentedSheet = nil
        AppLogger.ui.info("Dismissing sheet")
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
            if !routeHistory.isEmpty {
                routeHistory.removeLast()
            }
            AppLogger.ui.info("Navigated back")
        }
    }

    func goBackToRoot() {
        path = NavigationPath()
        routeHistory.removeAll()
        AppLogger.ui.info("Navigated to root")
    }

    private func routeDescription(for route: GameRoute) -> String {
        switch route {
        case .setup: return "Setup"
        case .gameplay: return "Gameplay"
        case .realPrice: return "RealPrice"
        case .results: return "Results"
        case .history: return "History"
        case .tutorial: return "Tutorial"
        case .ranking: return "Ranking"
        }
    }
}
