import Foundation

extension Array where Element == Player {
    func sortedByName() -> [Player] {
        sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

extension Array where Element == Restaurant {
    func sortedByDate() -> [Restaurant] {
        sorted { $0.dateCreated > $1.dateCreated }
    }
}

extension Array where Element == Game {
    func sortedByDate() -> [Game] {
        sorted { $0.datePlayed > $1.datePlayed }
    }

    func filteredByPlayer(_ playerId: UUID) -> [Game] {
        filter { game in
            game.participants.contains { $0.playerId == playerId }
        }
    }

    func filteredByRestaurant(_ restaurantId: UUID) -> [Game] {
        filter { $0.restaurant.id == restaurantId }
    }
}

extension Array where Element == Group {
    func sortedByName() -> [Group] {
        sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

extension Array where Element == GameResult {
    func playerStats(achievements: [PlayerAchievement] = []) -> [UUID: PlayerStats] {
        var stats: [UUID: PlayerStats] = [:]

        for result in self {
            if var existingStats = stats[result.playerId] {
                existingStats.totalGames += 1
                existingStats.totalPoints += result.points
                existingStats.averageDifference = ((existingStats.averageDifference * Double(existingStats.totalGames - 1)) + result.difference) / Double(existingStats.totalGames)

                if result.rank == 1 {
                    existingStats.wins += 1
                }

                stats[result.playerId] = existingStats
            } else {
                let playerAchievements = achievements.filter { $0.playerId == result.playerId }
                stats[result.playerId] = PlayerStats(
                    playerId: result.playerId,
                    playerName: result.playerName,
                    totalGames: 1,
                    totalPoints: result.points,
                    wins: result.rank == 1 ? 1 : 0,
                    averageDifference: result.difference,
                    achievements: playerAchievements
                )
            }
        }

        return stats
    }
}
