import Foundation
import SwiftUI
import OSLog

@MainActor
@Observable
class DataManager {
    static let shared = DataManager()

    var players: [Player] = []
    var restaurants: [Restaurant] = []
    var gameHistory: [Game] = []
    var groups: [Group] = []
    var achievements: [PlayerAchievement] {
        achievementService.getAllAchievements()
    }

    private let playersKey = "savedPlayers"
    private let restaurantsKey = "savedRestaurants"
    private let gameHistoryKey = "gameHistory"
    private let groupsKey = "savedGroups"

    private let achievementService = AchievementService()

    private init() {
        loadPlayers()
        loadRestaurants()
        loadGameHistory()
        loadGroups()
    }

    func loadPlayers() {
        AppLogger.data.info("Loading players from UserDefaults")

        if let cached: [Player] = CacheManager.shared.get(forKey: .players) {
            players = cached
            AppLogger.data.info("✅ Loaded \(self.players.count) players from cache")
            return
        }

        if let data = UserDefaults.standard.data(forKey: playersKey),
           let decoded = try? JSONDecoder().decode([Player].self, from: data) {
            players = decoded.sortedByName()
            CacheManager.shared.set(players, forKey: .players)
            AppLogger.data.info("✅ Loaded \(self.players.count) players")
        } else {
            AppLogger.data.info("No players found in UserDefaults")
        }
    }

    func savePlayers() {
        do {
            let encoded = try JSONEncoder().encode(players)
            UserDefaults.standard.set(encoded, forKey: playersKey)
            CacheManager.shared.set(players, forKey: .players)
            AppLogger.data.logDataOperation("save", entity: "Players", success: true)
        } catch {
            AppLogger.data.logError("Failed to save players", error: error)
        }
    }

    func addPlayer(_ player: Player) {
        let validation = Validator.validatePlayerName(player.name, existingPlayers: players)
        guard validation.isValid else {
            AppLogger.data.error("Failed to add player: \(validation.error?.localizedDescription ?? "Unknown error")")
            return
        }

        AppLogger.data.info("Adding player: \(player.name)")
        players.append(player)
        players = players.sortedByName()
        savePlayers()
    }

    func updatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
            players.sort { $0.name < $1.name }
            savePlayers()
        }
    }

    func deletePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
        savePlayers()
    }

    func loadRestaurants() {
        if let cached: [Restaurant] = CacheManager.shared.get(forKey: .restaurants) {
            restaurants = cached
            return
        }

        if let data = UserDefaults.standard.data(forKey: restaurantsKey),
           let decoded = try? JSONDecoder().decode([Restaurant].self, from: data) {
            restaurants = decoded.sortedByDate()
            CacheManager.shared.set(restaurants, forKey: .restaurants)
        }
    }

    func saveRestaurants() {
        do {
            let encoded = try JSONEncoder().encode(restaurants)
            UserDefaults.standard.set(encoded, forKey: restaurantsKey)
            CacheManager.shared.set(restaurants, forKey: .restaurants)
        } catch {
            AppLogger.data.logError("Failed to save restaurants", error: error)
        }
    }

    func addRestaurant(_ restaurant: Restaurant) {
        restaurants.insert(restaurant, at: 0)
        saveRestaurants()
    }

    func updateRestaurant(_ restaurant: Restaurant) {
        if let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
            restaurants[index] = restaurant
            saveRestaurants()
        }
    }

    func deleteRestaurant(_ restaurant: Restaurant) {
        restaurants.removeAll { $0.id == restaurant.id }
        saveRestaurants()
    }

    func loadGameHistory() {
        if let cached: [Game] = CacheManager.shared.get(forKey: .gameHistory) {
            gameHistory = cached
            return
        }

        if let data = UserDefaults.standard.data(forKey: gameHistoryKey),
           let decoded = try? JSONDecoder().decode([Game].self, from: data) {
            gameHistory = decoded.sortedByDate()
            CacheManager.shared.set(gameHistory, forKey: .gameHistory)
        }
    }

    func saveGameHistory() {
        do {
            let encoded = try JSONEncoder().encode(gameHistory)
            UserDefaults.standard.set(encoded, forKey: gameHistoryKey)
            CacheManager.shared.set(gameHistory, forKey: .gameHistory)
        } catch {
            AppLogger.data.logError("Failed to save game history", error: error)
        }
    }

    func addGame(_ game: Game) {
        AppLogger.game.info("Saving game: \(game.restaurant.name) - \(game.participants.count) players")
        gameHistory.insert(game, at: 0)
        saveGameHistory()

        // Check and award achievements for this game
        _ = achievementService.checkAndAwardAchievements(for: game, results: game.results, gameHistory: gameHistory)
    }

    func deleteGame(_ game: Game) {
        gameHistory.removeAll { $0.id == game.id }
        saveGameHistory()
    }

    /// Calculates game results using precision-based scoring.
    /// 1st: 6 points, 2nd: 3 points, 3rd: 1 point. Under-only mode disqualifies over-guesses.
    /// Calculates points based on rank with bonus for larger games (Hybrid System)
    private func calculatePoints(rank: Int, totalPlayers: Int) -> Int {
        // Base points for placement
        let basePoints: Int
        switch rank {
        case 1: basePoints = 10  // Winner
        case 2: basePoints = 7   // Second place
        case 3: basePoints = 5   // Third place
        case 4: basePoints = 3   // Fourth place
        case 5: basePoints = 2   // Fifth place
        default: basePoints = 1  // Participation
        }

        // Bonus for larger games (encourages social play)
        let participationBonus: Int
        switch totalPlayers {
        case 2...3: participationBonus = 0  // Small game
        case 4...5: participationBonus = 1  // Medium game (+1)
        case 6...7: participationBonus = 2  // Large game (+2)
        default: participationBonus = 3     // Epic game (+3 max)
        }

        return basePoints + participationBonus
    }

    func calculateResults(guesses: [PlayerGuess], actualPrice: Double, gameMode: GameMode) -> [GameResult] {
        var results = guesses.map { guess in
            GameResult(
                playerId: guess.playerId,
                playerName: guess.playerName,
                guessedPrice: guess.guessedPrice,
                actualPrice: actualPrice
            )
        }

        if gameMode == .underOnly {
            results = results.map { result in
                var modifiedResult = result
                if result.guessedPrice > actualPrice {
                    modifiedResult.points = -1
                }
                return modifiedResult
            }
        }

        let validResults = results.filter { $0.points != -1 }
        let disqualifiedResults = results.filter { $0.points == -1 }

        // Sort valid results by difference (closest first)
        var sortedValidResults = validResults.sorted { $0.difference < $1.difference }

        let totalPlayers = sortedValidResults.count

        // Assign ranks and points to valid results
        var currentRank = 1
        var previousDifference: Double?

        for i in 0..<sortedValidResults.count {
            // Check if this is a tie with the previous result
            if let prevDiff = previousDifference, abs(sortedValidResults[i].difference - prevDiff) < 0.01 {
                // Same rank as previous (tie)
                sortedValidResults[i].rank = currentRank
            } else {
                // New rank
                currentRank = i + 1
                sortedValidResults[i].rank = currentRank
            }

            // Calculate points using Hybrid System
            sortedValidResults[i].points = calculatePoints(rank: sortedValidResults[i].rank, totalPlayers: totalPlayers)

            previousDifference = sortedValidResults[i].difference
        }

        let finalDisqualifiedResults = disqualifiedResults.map { result in
            var modifiedResult = result
            modifiedResult.rank = sortedValidResults.count + 1
            modifiedResult.points = 0
            return modifiedResult
        }

        return sortedValidResults + finalDisqualifiedResults
    }

    func loadGroups() {
        if let cached: [Group] = CacheManager.shared.get(forKey: .groups) {
            groups = cached
            return
        }

        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([Group].self, from: data) {
            groups = decoded.sortedByName()
            CacheManager.shared.set(groups, forKey: .groups)
        }
    }

    func saveGroups() {
        do {
            let encoded = try JSONEncoder().encode(groups)
            UserDefaults.standard.set(encoded, forKey: groupsKey)
            CacheManager.shared.set(groups, forKey: .groups)
        } catch {
            AppLogger.data.logError("Failed to save groups", error: error)
        }
    }

    func addGroup(_ group: Group) {
        groups.append(group)
        groups.sort { $0.name < $1.name }
        saveGroups()
    }

    func updateGroup(_ group: Group) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            groups.sort { $0.name < $1.name }
            saveGroups()
        }
    }

    func deleteGroup(_ group: Group) {
        groups.removeAll { $0.id == group.id }
        saveGroups()
    }

    func getPlayers(for group: Group) -> [Player] {
        return players.filter { group.playerIds.contains($0.id) }
    }

    func getAchievements(for playerId: UUID) -> [PlayerAchievement] {
        achievementService.getAchievements(for: playerId)
    }
}
