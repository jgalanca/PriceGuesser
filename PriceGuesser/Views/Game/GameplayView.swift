import SwiftUI

struct GameplayView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(GameRouter.self) private var router
    @Environment(AppSettings.self) private var settings

    let restaurant: Restaurant
    let players: [Player]
    let currency: Currency
    let gameMode: GameMode

    @State private var shuffledPlayers: [Player] = []
    @State private var currentPlayerIndex = 0
    @State private var guesses: [PlayerGuess] = []
    @State private var isAnimating = false

    var currentPlayer: Player? {
        guard currentPlayerIndex < shuffledPlayers.count else { return nil }
        return shuffledPlayers[currentPlayerIndex]
    }

    var allGuessesEntered: Bool {
        guesses.count == shuffledPlayers.count
    }

    var body: some View {
        VStack {
            if allGuessesEntered {
                // All guesses entered, ready for real price
                VStack(spacing: 30) {
                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("successColor"))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                        .accessibilityHidden(true)

                    VStack(spacing: 12) {
                        Text("All guesses are in!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)

                        Text("Ready to reveal the real price?")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    Button {
                        HapticManager.impact(style: .medium)
                        router.navigate(to: .realPrice(restaurant: restaurant, guesses: guesses, currency: currency, gameMode: gameMode))
                    } label: {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                            Text("realPrice.enterPrice".localized)
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color("brandPrimary"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    .accessibilityLabel("Enter real price")
                    .accessibilityHint("Proceeds to enter the actual price of the meal")
                }
                .onAppear {
                    isAnimating = true
                }
            } else if let player = currentPlayer {
                // Show current player's turn
                VStack(spacing: 40) {
                    Spacer()

                    // Player Info
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color("brandPrimary"))
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                            .accessibilityHidden(true)

                        VStack(spacing: 8) {
                            Text(player.name)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .accessibilityAddTraits(.isHeader)

                            Text("gameplay.title".localized)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }

                        // Restaurant name
                        VStack(spacing: 8) {
                            Text("Restaurant")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(restaurant.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("AccentColor"))
                        }
                        .padding()
                        .background(Color("cardBackground"))
                        .cornerRadius(12)
                    }

                    // Progress indicator
                    VStack(spacing: 8) {
                        Text("Player \(currentPlayerIndex + 1) of \(shuffledPlayers.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ProgressView(value: Double(currentPlayerIndex), total: Double(shuffledPlayers.count))
                            .tint(Color("brandPrimary"))
                            .scaleEffect(y: 2)
                            .padding(.horizontal, 60)
                    }

                    Spacer()

                    // Start Button
                    Button {
                        HapticManager.impact(style: .medium)
                        if let player = currentPlayer {
                            router.presentSheet(.guessInput(player: player) { guess in
                                addGuess(guess)
                            })
                        }
                    } label: {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                            Text("gameplay.enterYourGuess".localized)
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color("brandPrimary"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color("brandPrimary").opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
                .onAppear {
                    isAnimating = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor").ignoresSafeArea())
        .sheet(item: Bindable(router).presentedSheet) { sheet in
            switch sheet {
            case let .guessInput(player, onSubmit):
                GuessInputView(player: player, currency: currency, onSubmit: onSubmit)
                    .environment(router)
            }
        }
        .onAppear {
            // Shuffle players once when view appears
            if shuffledPlayers.isEmpty {
                shuffledPlayers = players.shuffled()
            }
        }
    }

    private func addGuess(_ amount: Double) {
        guard let player = currentPlayer else { return }

        let guess = PlayerGuess(
            playerId: player.id,
            playerName: player.name,
            guessedPrice: amount
        )

        guesses.append(guess)
        HapticManager.notification(type: .success)

        // Move to next player or finish
        if currentPlayerIndex < shuffledPlayers.count - 1 {
            currentPlayerIndex += 1
            isAnimating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = true
            }
        }
    }
}

struct GuessInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameRouter.self) private var router
    let player: Player
    let currency: Currency
    let onSubmit: (Double) -> Void

    @State private var guessText = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("brandPrimary"))

                Text(player.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("gameplay.subtitle".localized)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // Input field
            VStack(alignment: .leading, spacing: 8) {
                Text("gameplay.enterGuess".localized)
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack {
                    Text(currency.symbol)
                        .font(.title)
                        .foregroundColor(.secondary)

                    TextField("0.00", text: $guessText)
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

            // Confirm Button
            Button {
                submitGuess()
            } label: {
                Text("gameplay.submitGuess".localized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color("brandPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            .disabled(guessText.isEmpty)
            .opacity(guessText.isEmpty ? 0.5 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor").ignoresSafeArea())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    private func submitGuess() {
        guard let amount = Double(guessText.replacingOccurrences(of: ",", with: ".")),
              amount > 0 else {
            HapticManager.notification(type: .error)
            return
        }

        HapticManager.notification(type: .success)
        onSubmit(amount)
        router.dismissSheet()
    }
}

#if DEBUG
#Preview("Closest Mode - 4 Players") {
    GameplayView(
        restaurant: Restaurant(name: "La Trattoria Romana", googleMapsLink: "https://maps.google.com/?q=Trattoria"),
        players: [
            Player(name: "Emma"),
            Player(name: "Liam"),
            Player(name: "Olivia"),
            Player(name: "Noah")
        ],
        currency: Currency(code: "EUR", symbol: "€", name: "Euro"),
        gameMode: .closest
    )
    .environment(DataManager.shared)
    .environment(GameRouter())
    .environment(AppSettings.shared)
}

#Preview("Exact Mode - 3 Players") {
    GameplayView(
        restaurant: Restaurant(name: "Burger Supreme", googleMapsLink: nil),
        players: [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ],
        currency: Currency(code: "USD", symbol: "$", name: "US Dollar"),
        gameMode: .closest
    )
    .environment(DataManager.shared)
    .environment(GameRouter())
    .environment(AppSettings.shared)
}

#Preview("6 Players") {
    GameplayView(
        restaurant: Restaurant(name: "Sushi Master"),
        players: [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3"),
            Player(name: "Player 4"),
            Player(name: "Player 5"),
            Player(name: "Player 6")
        ],
        currency: Currency.detectFromLocale(),
        gameMode: .closest
    )
    .environment(DataManager.shared)
    .environment(GameRouter())
    .environment(AppSettings.shared)
}
#endif
