import SwiftUI

struct PlayerRanking: Identifiable {
    let id: UUID
    let name: String
    let totalPoints: Int
    let gamesPlayed: Int
    let averagePoints: Double
    let rank: Int
}

struct RankingView: View {
    @Environment(DataManager.self) private var dataManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if rankings.isEmpty {
                    ContentUnavailableView(
                        "ranking.empty".localized,
                        systemImage: "trophy.fill",
                        description: Text("ranking.emptyDescription".localized)
                    )
                    .padding(.top, 100)
                } else {
                    // Top 3 Podium
                    if rankings.count >= 3 {
                        PodiumView(rankings: Array(rankings.prefix(3)))
                            .padding(.top, 20)
                    }

                    // Full Rankings List
                    VStack(spacing: 12) {
                        ForEach(rankings) { ranking in
                            RankingRowView(ranking: ranking)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color("backgroundColor").ignoresSafeArea())
        .navigationTitle("ranking.title".localized)
        .navigationBarTitleDisplayMode(.large)
    }

    private struct PlayerStats {
        var name: String
        var points: Int
        var games: Int
    }

    private var rankings: [PlayerRanking] {
        // Calculate total points for each player
        var playerStats: [UUID: PlayerStats] = [:]

        for game in dataManager.gameHistory {
            for result in game.results {
                if var stats = playerStats[result.playerId] {
                    stats.points += result.points
                    stats.games += 1
                    playerStats[result.playerId] = stats
                } else {
                    playerStats[result.playerId] = PlayerStats(
                        name: result.playerName,
                        points: result.points,
                        games: 1
                    )
                }
            }
        }

        // Convert to PlayerRanking and sort by total points
        let sortedRankings = playerStats.map { id, stats in
            PlayerRanking(
                id: id,
                name: stats.name,
                totalPoints: stats.points,
                gamesPlayed: stats.games,
                averagePoints: Double(stats.points) / Double(stats.games),
                rank: 0
            )
        }
        .sorted { $0.totalPoints > $1.totalPoints }

        // Assign ranks
        return sortedRankings.enumerated().map { index, ranking in
            PlayerRanking(
                id: ranking.id,
                name: ranking.name,
                totalPoints: ranking.totalPoints,
                gamesPlayed: ranking.gamesPlayed,
                averagePoints: ranking.averagePoints,
                rank: index + 1
            )
        }
    }
}

// MARK: - Podium View
struct PodiumView: View {
    let rankings: [PlayerRanking]

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            // 2nd Place
            if rankings.count > 1 {
                PodiumCard(ranking: rankings[1], height: 120, medal: "🥈")
            }

            // 1st Place
            PodiumCard(ranking: rankings[0], height: 160, medal: "🥇")

            // 3rd Place
            if rankings.count > 2 {
                PodiumCard(ranking: rankings[2], height: 100, medal: "🥉")
            }
        }
        .padding(.horizontal, 20)
    }
}

struct PodiumCard: View {
    let ranking: PlayerRanking
    let height: CGFloat
    let medal: String

    private var position: String {
        switch ranking.rank {
        case 1: return "First"
        case 2: return "Second"
        case 3: return "Third"
        default: return "\(ranking.rank)th"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(medal)
                .font(.system(size: 40))
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(ranking.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("\(ranking.totalPoints) " + "ranking.points".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("brandPrimary"))
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color("brandPrimary").opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("brandPrimary").opacity(0.3), lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(position) place: \(ranking.name), \(ranking.totalPoints) points")
    }
}

// MARK: - Ranking Row View
struct RankingRowView: View {
    let ranking: PlayerRanking

    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Text("\(ranking.rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)
            }

            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(ranking.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text("\(ranking.gamesPlayed) " + "ranking.games".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.1f", ranking.averagePoints) + " " + "ranking.avgPoints".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Total Points
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(ranking.totalPoints)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brandPrimary"))

                Text("ranking.points".localized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color("cardBackground"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ranking.rank <= 3 ? rankColor.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: ranking.rank <= 3 ? 2 : 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        """
        Rank \(ranking.rank): \(ranking.name). \
        Total points: \(ranking.totalPoints). \
        Games played: \(ranking.gamesPlayed). \
        Average points: \(String(format: "%.1f", ranking.averagePoints))
        """
    }

    private var rankColor: Color {
        switch ranking.rank {
        case 1:
            return .yellow
        case 2:
            return .gray
        case 3:
            return .orange
        default:
            return Color("brandPrimary")
        }
    }
}

#if DEBUG
extension DataManager {
    static var mockWithRankings: DataManager {
        let manager = DataManager.shared

        // Create mock players
        let players = [
            Player(name: "Emma"),
            Player(name: "Liam"),
            Player(name: "Olivia"),
            Player(name: "Noah"),
            Player(name: "Ava"),
            Player(name: "Sophia"),
            Player(name: "Jackson")
        ]
        players.forEach { manager.addPlayer($0) }

        // Create mock game history with varying results
        let restaurants = ["La Pizzeria", "Sushi Bar", "Burger House", "Thai Kitchen", "Steakhouse"]
        let gameResults: [(playerIndex: Int, points: Int)] = [
            (0, 10), (1, 8), (2, 6), (3, 4), (4, 2),  // Game 1: Emma wins
            (1, 10), (0, 8), (4, 6), (2, 4), (3, 2),  // Game 2: Liam wins
            (2, 10), (1, 8), (0, 6), (5, 4), (3, 2),  // Game 3: Olivia wins
            (0, 10), (2, 8), (1, 6), (4, 4), (5, 2),  // Game 4: Emma wins again
            (1, 10), (3, 8), (0, 6), (2, 4), (4, 2),  // Game 5: Liam wins again
            (3, 10), (1, 8), (2, 6), (0, 4), (5, 2),  // Game 6: Noah wins
            (0, 10), (1, 8), (3, 6), (2, 4), (6, 2)   // Game 7: Emma wins (3rd time)
        ]

        for (gameIndex, restaurant) in restaurants.enumerated() {
            let actualPrice = Double.random(in: 40...70)
            let gamePlayers = Array(players.prefix(5))

            let guesses = gamePlayers.map { player in
                PlayerGuess(
                    playerId: player.id,
                    playerName: player.name,
                    guessedPrice: Double.random(in: 30...80)
                )
            }

            let gameResultsForThisGame = gameResults.filter { $0.playerIndex < players.count }
                .prefix(5)
                .enumerated()
                .map { index, result in
                    let guess = guesses.first { $0.playerId == players[result.playerIndex].id }?.guessedPrice ?? actualPrice
                    return GameResult(
                        playerId: players[result.playerIndex].id,
                        playerName: players[result.playerIndex].name,
                        guessedPrice: guess,
                        actualPrice: actualPrice,
                        points: result.points,
                        rank: index + 1
                    )
                }

            let game = Game(
                restaurant: Restaurant(name: restaurant),
                datePlayed: Date().addingTimeInterval(TimeInterval(-86400 * gameIndex)),
                participants: guesses,
                actualPrice: actualPrice,
                results: gameResultsForThisGame,
                currencyCode: Currency.detectFromLocale().code,
                gameMode: .closest
            )

            manager.addGame(game)
        }

        return manager
    }
}

#Preview("Rankings with Data") {
    NavigationStack {
        RankingView()
            .environment(DataManager.mockWithRankings)
    }
}

#Preview("Empty Rankings") {
    NavigationStack {
        RankingView()
            .environment(DataManager.shared)
    }
}
#endif
