import SwiftUI

struct RealPriceInputView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(GameRouter.self) private var router

    let restaurant: Restaurant
    let guesses: [PlayerGuess]
    let currency: Currency
    let gameMode: GameMode

    @State private var priceText = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Header
            VStack(spacing: 16) {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("brandPrimary"))

                VStack(spacing: 8) {
                    Text("realPrice.title".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(restaurant.name)
                        .font(.title3)
                        .foregroundColor(Color("AccentColor"))
                        .fontWeight(.semibold)
                }

                Text("realPrice.subtitle".localized)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // Input field
            VStack(alignment: .leading, spacing: 8) {
                Text("realPrice.enterPrice".localized)
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack {
                    Text(currency.symbol)
                        .font(.title)
                        .foregroundColor(.secondary)

                    TextField("0.00", text: $priceText)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color("cardBackground"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("brandPrimary"), lineWidth: 2)
                )
            }
            .padding(.horizontal, 30)

            Spacer()

            // Show Results Button
            Button {
                calculateAndShowResults()
            } label: {
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Text("realPrice.showResults".localized)
                }
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color("brandPrimary"))
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color("brandPrimary").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            .disabled(priceText.isEmpty)
            .opacity(priceText.isEmpty ? 0.5 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor").ignoresSafeArea())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    private func calculateAndShowResults() {
        guard let actualPrice = Double(priceText.replacingOccurrences(of: ",", with: ".")),
              actualPrice > 0 else {
            HapticManager.notification(type: .error)
            return
        }

        // Calculate results
        let calculatedResults = dataManager.calculateResults(guesses: guesses, actualPrice: actualPrice, gameMode: gameMode)

        // Save game to history
        let game = Game(
            restaurant: restaurant,
            participants: guesses,
            actualPrice: actualPrice,
            results: calculatedResults,
            currencyCode: currency.code,
            gameMode: gameMode
        )
        dataManager.addGame(game)

        HapticManager.notification(type: .success)
        router.navigate(to: .results(restaurant: restaurant, actualPrice: actualPrice, results: calculatedResults, currency: currency, gameMode: gameMode))
    }
}

#if DEBUG
#Preview("Closest Mode - 5 Players") {
    RealPriceInputView(
        restaurant: Restaurant(name: "La Bella Vita", googleMapsLink: "https://maps.google.com"),
        guesses: [
            PlayerGuess(playerId: UUID(), playerName: "Emma", guessedPrice: 68.50),
            PlayerGuess(playerId: UUID(), playerName: "Liam", guessedPrice: 72.00),
            PlayerGuess(playerId: UUID(), playerName: "Olivia", guessedPrice: 65.30),
            PlayerGuess(playerId: UUID(), playerName: "Noah", guessedPrice: 80.00),
            PlayerGuess(playerId: UUID(), playerName: "Ava", guessedPrice: 55.75)
        ],
        currency: Currency(code: "EUR", symbol: "€", name: "Euro"),
        gameMode: .closest
    )
    .environment(DataManager.shared)
    .environment(GameRouter())
}

#Preview("Exact Mode - 3 Players") {
    RealPriceInputView(
        restaurant: Restaurant(name: "Sushi Paradise"),
        guesses: [
            PlayerGuess(playerId: UUID(), playerName: "Alice", guessedPrice: 45.00),
            PlayerGuess(playerId: UUID(), playerName: "Bob", guessedPrice: 52.50),
            PlayerGuess(playerId: UUID(), playerName: "Charlie", guessedPrice: 48.75)
        ],
        currency: Currency(code: "USD", symbol: "$", name: "US Dollar"),
        gameMode: .underOnly
    )
    .environment(DataManager.shared)
    .environment(GameRouter())
}
#endif
