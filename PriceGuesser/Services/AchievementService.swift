import Foundation

@MainActor
final class AchievementService {
    private let achievementsKey = "playerAchievements"
    private var achievements: [PlayerAchievement] = []

    init() {
        loadAchievements()
    }

    func loadAchievements() {
        if let cached: [PlayerAchievement] = CacheManager.shared.get(forKey: .gameHistory) {
            achievements = cached
            return
        }

        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([PlayerAchievement].self, from: data) {
            achievements = decoded
            CacheManager.shared.set(achievements, forKey: .gameHistory)
        }
    }

    func saveAchievements() {
        do {
            let encoded = try JSONEncoder().encode(achievements)
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
            CacheManager.shared.set(achievements, forKey: .gameHistory)
        } catch {
            AppLogger.data.logError("Failed to save achievements", error: error)
        }
    }

    func checkAndAwardAchievements(for game: Game, results: [GameResult], gameHistory: [Game]) -> [PlayerAchievement] {
        var newAchievements: [PlayerAchievement] = []

        for result in results {
            checkAccuracyAchievements(for: result, game: game, newAchievements: &newAchievements)
            checkFirstWinAchievement(for: result, game: game, gameHistory: gameHistory, newAchievements: &newAchievements)
            checkSocialAchievements(for: result, game: game, gameHistory: gameHistory, newAchievements: &newAchievements)
        }

        checkStreakAchievements(for: game, results: results, gameHistory: gameHistory, newAchievements: &newAchievements)
        checkMilestoneAchievements(for: results, gameHistory: gameHistory, newAchievements: &newAchievements)

        if !newAchievements.isEmpty {
            achievements.append(contentsOf: newAchievements)
            saveAchievements()
        }

        return newAchievements
    }

    private func checkAccuracyAchievements(for result: GameResult, game: Game, newAchievements: inout [PlayerAchievement]) {
        let percentageDiff = (result.difference / result.actualPrice) * 100

        // Perfect Guess (within 1% or exact)
        if percentageDiff <= 1.0 && !hasAchievement(playerId: result.playerId, type: .perfectGuess, gameId: game.id) {
            newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .perfectGuess, gameId: game.id))
        }

        // Close Call (within 5%)
        if percentageDiff <= 5.0 && percentageDiff > 1.0 && !hasAchievement(playerId: result.playerId, type: .closeCall, gameId: game.id) {
            newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .closeCall, gameId: game.id))
        }
    }

    private func checkFirstWinAchievement(for result: GameResult, game: Game, gameHistory: [Game], newAchievements: inout [PlayerAchievement]) {
        guard result.rank == 1 else { return }

        let playerWins = gameHistory.filter { game in
            game.results.contains { $0.playerId == result.playerId && $0.rank == 1 }
        }.count

        if playerWins == 1 && !hasAchievement(playerId: result.playerId, type: .firstWin) {
            newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .firstWin, gameId: game.id))
        }
    }

    private func checkSocialAchievements(for result: GameResult, game: Game, gameHistory: [Game], newAchievements: inout [PlayerAchievement]) {
        // Group Host (8+ players)
        if game.participants.count >= 8 && !hasAchievement(playerId: result.playerId, type: .groupHost, gameId: game.id) {
            newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .groupHost, gameId: game.id))
        }

        // Social Butterfly (played with 20+ different players)
        let playerGames = gameHistory.filter { game in
            game.participants.contains { $0.playerId == result.playerId }
        }
        let uniquePlayers = Set(playerGames.flatMap { $0.participants.map { $0.playerId } }).count
        if uniquePlayers >= 20 && !hasAchievement(playerId: result.playerId, type: .socialButterfly) {
            newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .socialButterfly))
        }
    }

    private func checkStreakAchievements(for game: Game, results: [GameResult], gameHistory: [Game], newAchievements: inout [PlayerAchievement]) {
        for result in results where result.rank == 1 {
            let recentGames = gameHistory.suffix(3)
            let recentWins = recentGames.filter { game in
                game.results.first { $0.playerId == result.playerId }?.rank == 1
            }

            if recentWins.count == 3 && !hasAchievement(playerId: result.playerId, type: .consistentWinner) {
                newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .consistentWinner, gameId: game.id))
            }
        }
    }

    private func checkMilestoneAchievements(for results: [GameResult], gameHistory: [Game], newAchievements: inout [PlayerAchievement]) {
        for result in results {
            let playerGameCount = gameHistory.filter { game in
                game.participants.contains { $0.playerId == result.playerId }
            }.count

            // Veteran (50 games)
            if playerGameCount >= 50 && !hasAchievement(playerId: result.playerId, type: .veteran) {
                newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .veteran))
            }

            // Centurion (100 games)
            if playerGameCount >= 100 && !hasAchievement(playerId: result.playerId, type: .centurion) {
                newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .centurion))
            }

            // Sharp Shooter (10+ perfect guesses)
            let perfectGuesses = achievements.filter { $0.playerId == result.playerId && $0.type == .perfectGuess }.count
            if perfectGuesses >= 10 && !hasAchievement(playerId: result.playerId, type: .sharpShooter) {
                newAchievements.append(PlayerAchievement(playerId: result.playerId, type: .sharpShooter))
            }
        }
    }

    private func hasAchievement(playerId: UUID, type: AchievementType, gameId: UUID? = nil) -> Bool {
        if let gameId = gameId {
            return achievements.contains { $0.playerId == playerId && $0.type == type && $0.gameId == gameId }
        }
        return achievements.contains { $0.playerId == playerId && $0.type == type }
    }

    func getAchievements(for playerId: UUID) -> [PlayerAchievement] {
        achievements.filter { $0.playerId == playerId }.sorted { $0.dateEarned > $1.dateEarned }
    }

    func getAllAchievements() -> [PlayerAchievement] {
        achievements
    }
}
