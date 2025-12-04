import SwiftUI

struct GameHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager

    @State private var selectedGame: Game?

    var body: some View {
        VStack {
            if dataManager.gameHistory.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "clock.badge.questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)

                    Text("history.empty".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("history.noGames".localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(dataManager.gameHistory) { game in
                            GameHistoryCard(game: game) {
                                HapticManager.impact(style: .light)
                                selectedGame = game
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor").ignoresSafeArea())
        .navigationTitle("history.title".localized)
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedGame) { game in
            NavigationStack {
                GameDetailView(game: game)
                    .environment(dataManager)
            }
        }
    }
}

struct GameHistoryCard: View {
    let game: Game
    let onTap: () -> Void

    var winner: GameResult? {
        game.results.first { $0.rank == 1 }
    }

    private var accessibilityLabel: String {
        let dateString = DateFormatterHelper.formatShort(game.datePlayed)
        let priceString = CurrencyFormatter.format(game.actualPrice, currency: game.currency)
        let playersCount = game.participants.count
        let winnerString = winner?.playerName ?? "Unknown"

        return """
        Game at \(game.restaurant.name), \(dateString). \
        Actual price: \(priceString). \
        \(playersCount) players. \
        Winner: \(winnerString)
        """
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.restaurant.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text(DateFormatterHelper.formatShort(game.datePlayed))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                }

                Divider()

                // Info
                HStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("results.actualPrice".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(CurrencyFormatter.format(game.actualPrice, currency: game.currency))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("brandPrimary"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("history.players".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(game.participants.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("brandSecondary"))
                    }

                    Spacer()
                }

                // Winner
                if let winner = winner {
                    HStack(spacing: 8) {
                        Text("🥇")
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("history.winner".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(winner.playerName)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(Color("cardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view game details")
        .accessibilityAddTraits(.isButton)
    }
}

struct GameDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager

    let game: Game
    @State private var showDeleteAlert = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Restaurant Info
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("brandPrimary"))
                            .accessibilityHidden(true)

                        Text(game.restaurant.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        if let link = game.restaurant.googleMapsLink, !link.isEmpty {
                            Link(destination: URL(string: link) ?? URL(string: "https://maps.google.com")!) {
                                HStack(spacing: 4) {
                                    Image(systemName: "map.fill")
                                    Text("View on Maps")
                                }
                                .font(.subheadline)
                                .foregroundColor(Color("brandSecondary"))
                            }
                            .accessibilityLabel("Open \(game.restaurant.name) in Maps")
                            .accessibilityHint("Opens location in Maps app")
                        }

                        Text(DateFormatterHelper.format(game.datePlayed))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // Actual Price
                    VStack(spacing: 4) {
                        Text("results.actualPrice".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(CurrencyFormatter.format(game.actualPrice, currency: game.currency))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(Color("brandPrimary"))
                    }
                    .padding()
                    .background(Color("brandPrimary").opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Actual price: \(CurrencyFormatter.format(game.actualPrice, currency: game.currency))")

                    // Results
                    VStack(spacing: 12) {
                        ForEach(Array(game.results.enumerated()), id: \.element.id) { index, result in
                            ResultCard(result: result, index: index, currency: game.currency)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Delete Button
                    Button(role: .destructive) {
                        HapticManager.impact(style: .medium)
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("common.delete".localized)
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .accessibilityLabel("Delete game")
                    .accessibilityHint("Opens confirmation dialog")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.impact(style: .light)
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert("Delete Game", isPresented: $showDeleteAlert) {
            Button("common.cancel".localized, role: .cancel) { }
            Button("common.delete".localized, role: .destructive) {
                dataManager.deleteGame(game)
                HapticManager.notification(type: .success)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this game?")
        }
    }
}

#if DEBUG
extension DataManager {
    static var mockWithHistory: DataManager {
        let manager = DataManager.shared

        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie"),
            Player(name: "Diana")
        ]
        players.forEach { manager.addPlayer($0) }

        struct GameData {
            let restaurant: String
            let actualPrice: Double
            let winner: String
            let date: TimeInterval
        }

        let gamesData: [GameData] = [
            GameData(restaurant: "La Bella Italia", actualPrice: 68.50, winner: "Alice", date: -86400),
            GameData(restaurant: "Sushi Master", actualPrice: 92.00, winner: "Bob", date: -172800),
            GameData(restaurant: "Burger Palace", actualPrice: 45.30, winner: "Charlie", date: -259200),
            GameData(restaurant: "Thai Spice", actualPrice: 55.75, winner: "Diana", date: -345600),
            GameData(restaurant: "Steakhouse Premium", actualPrice: 125.00, winner: "Alice", date: -432000),
            GameData(restaurant: "Taco Fiesta", actualPrice: 38.20, winner: "Bob", date: -518400)
        ]

        for gameData in gamesData {
            let guesses = players.map { player in
                let isWinner = player.name == gameData.winner
                let guess = isWinner ? gameData.actualPrice + Double.random(in: -2...2) : gameData.actualPrice + Double.random(in: -15...15)
                return PlayerGuess(playerId: player.id, playerName: player.name, guessedPrice: guess)
            }

            let results = players.enumerated().map { index, player in
                let isWinner = player.name == gameData.winner
                let guess = guesses.first { $0.playerId == player.id }?.guessedPrice ?? gameData.actualPrice
                return GameResult(
                    playerId: player.id,
                    playerName: player.name,
                    guessedPrice: guess,
                    actualPrice: gameData.actualPrice,
                    points: isWinner ? 10 : Int.random(in: 2...8),
                    rank: isWinner ? 1 : index + 1
                )
            }

            let game = Game(
                restaurant: Restaurant(name: gameData.restaurant, googleMapsLink: "https://maps.google.com"),
                datePlayed: Date().addingTimeInterval(gameData.date),
                participants: guesses,
                actualPrice: gameData.actualPrice,
                results: results,
                currencyCode: Currency.detectFromLocale().code,
                gameMode: .closest
            )

            manager.addGame(game)
        }

        return manager
    }
}

#Preview("With Game History") {
    NavigationView {
        GameHistoryView()
            .environment(DataManager.mockWithHistory)
    }
}

#Preview("Empty History") {
    NavigationView {
        GameHistoryView()
            .environment(DataManager.shared)
    }
}
#endif
