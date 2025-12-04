import SwiftUI

struct ResultsView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(GameRouter.self) private var router

    let restaurant: Restaurant
    let actualPrice: Double
    let results: [GameResult]
    let currency: Currency
    let gameMode: GameMode

    @State private var showConfetti = false
    @State private var animateResults = false

    init(restaurant: Restaurant, actualPrice: Double, results: [GameResult], currency: Currency, gameMode: GameMode) {
        self.restaurant = restaurant
        self.actualPrice = actualPrice
        self.results = results
        self.currency = currency
        self.gameMode = gameMode
        print("DEBUG: ResultsView initialized with \(results.count) results")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "trophy.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.yellow)
                        .scaleEffect(showConfetti ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: showConfetti)
                        .accessibilityHidden(true)

                    Text("results.title".localized)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .accessibilityAddTraits(.isHeader)

                    // Restaurant info
                    VStack(spacing: 8) {
                        Text("results.restaurant".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(restaurant.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("AccentColor"))

                        if let link = restaurant.googleMapsLink, !link.isEmpty {
                            Link(destination: URL(string: link) ?? URL(string: "https://maps.google.com")!) {
                                HStack(spacing: 4) {
                                    Image(systemName: "map.fill")
                                    Text("View on Maps")
                                }
                                .font(.caption)
                                .foregroundColor(Color("brandSecondary"))
                            }
                            .accessibilityLabel("Open \(restaurant.name) in Maps")
                        }
                    }
                    .padding()
                    .background(Color("cardBackground"))
                    .cornerRadius(12)
                    .accessibilityElement(children: .contain)

                    // Actual price
                    VStack(spacing: 4) {
                        Text("results.actualPrice".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(CurrencyFormatter.format(actualPrice, currency: currency))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(Color("brandPrimary"))
                    }
                    .padding()
                    .background(Color("brandPrimary").opacity(0.1))
                    .cornerRadius(16)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Actual price: \(CurrencyFormatter.format(actualPrice, currency: currency))")
                    .accessibilityAddTraits(.isStaticText)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // Results List
                VStack(spacing: 12) {
                    ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                        ResultCard(result: result, index: index, currency: currency)
                            .opacity(animateResults ? 1 : 0.3)
                            .offset(y: animateResults ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateResults)
                    }
                }
                .padding(.horizontal, 20)

                // Action Buttons
                VStack(spacing: 16) {
                    // Back to Home Button
                    Button {
                        HapticManager.impact(style: .light)
                        router.goBackToRoot()
                    } label: {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("results.backHome".localized)
                        }
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color("cardBackground"))
                        .foregroundColor(Color("brandSecondary"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("brandSecondary"), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor").ignoresSafeArea())
        .onAppear {
            showConfetti = true
            HapticManager.notification(type: .success)

            // Delay animation to allow navigation transition to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateResults = true
            }
        }
    }
}

struct ResultCard: View {
    let result: GameResult
    let index: Int
    let currency: Currency

    var medalIcon: String {
        switch result.rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    var rankColor: Color {
        switch result.rank {
        case 1: return Color.yellow
        case 2: return Color.gray
        case 3: return Color.orange
        default: return Color("brandPrimary")
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header with rank
            HStack {
                HStack(spacing: 8) {
                    if !medalIcon.isEmpty {
                        Text(medalIcon)
                            .font(.title)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.playerName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        if result.rank <= 3 {
                            Text(result.rank == 1 ? "results.winner".localized : "\(result.rank)\(ordinalSuffix(result.rank)) Place")
                                .font(.caption)
                                .foregroundColor(rankColor)
                                .fontWeight(.semibold)
                        }
                    }
                }

                Spacer()

                // Points badge
                VStack(spacing: 2) {
                    Text("\(result.points)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(rankColor)
                    Text("results.points".localized)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(rankColor.opacity(0.15))
                .cornerRadius(12)
            }

            Divider()

            // Details
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(
                        label: "results.guess".localized,
                        value: CurrencyFormatter.format(result.guessedPrice, currency: currency),
                        color: .primary
                    )

                    DetailRow(
                        label: "results.difference".localized,
                        value: CurrencyFormatter.format(result.difference, currency: currency),
                        color: Color("brandSecondary")
                    )
                }

                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cardBackground"))
                .shadow(color: result.rank == 1 ? rankColor.opacity(0.3) : Color.black.opacity(0.05), radius: result.rank == 1 ? 15 : 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(result.rank == 1 ? rankColor.opacity(0.5) : Color.clear, lineWidth: result.rank == 1 ? 2 : 0)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let position = result.rank == 1 ? "Winner" : "Rank \(result.rank)"
        let guess = CurrencyFormatter.format(result.guessedPrice, currency: currency)
        let difference = CurrencyFormatter.format(abs(result.difference), currency: currency)
        let offBy = result.difference > 0 ? "over by" : "under by"

        return """
        \(position): \(result.playerName). \
        Guessed \(guess), \(offBy) \(difference). \
        Earned \(result.points) points
        """
    }

    func ordinalSuffix(_ number: Int) -> String {
        switch number {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#if DEBUG
extension ResultsView {
    static var mockData: ResultsView {
        let players = [
            (id: UUID(), name: "Emma", guess: 62.0, points: 10),
            (id: UUID(), name: "Liam", guess: 58.0, points: 8),
            (id: UUID(), name: "Olivia", guess: 55.0, points: 6),
            (id: UUID(), name: "Noah", guess: 70.0, points: 4),
            (id: UUID(), name: "Ava", guess: 45.0, points: 2)
        ]

        let actualPrice = 60.0
        let results = players.enumerated().map { index, player in
            GameResult(
                playerId: player.id,
                playerName: player.name,
                guessedPrice: player.guess,
                actualPrice: actualPrice,
                points: player.points,
                rank: index + 1
            )
        }

        return ResultsView(
            restaurant: Restaurant(
                name: "La Trattoria Italiana",
                googleMapsLink: "https://maps.google.com/?q=La+Trattoria+Italiana"
            ),
            actualPrice: actualPrice,
            results: results,
            currency: Currency(code: "EUR", symbol: "€", name: "Euro"),
            gameMode: .closest
        )
    }
}

#Preview("Closest Mode - 5 Players") {
    ResultsView.mockData
        .environment(DataManager.shared)
        .environment(GameRouter())
}

#Preview("Exact Mode - 3 Players") {
    let results = [
        GameResult(playerId: UUID(), playerName: "Sarah", guessedPrice: 42.50, actualPrice: 42.50, points: 10, rank: 1),
        GameResult(playerId: UUID(), playerName: "Mike", guessedPrice: 43.0, actualPrice: 42.50, points: 5, rank: 2),
        GameResult(playerId: UUID(), playerName: "Alex", guessedPrice: 38.0, actualPrice: 42.50, points: 0, rank: 3)
    ]

    ResultsView(
        restaurant: Restaurant(name: "Sushi Paradise", googleMapsLink: nil),
        actualPrice: 42.50,
        results: results,
        currency: Currency(code: "USD", symbol: "$", name: "US Dollar"),
        gameMode: .closest
    )
    .environment(DataManager.shared)
    .environment(GameRouter())
}
#endif
