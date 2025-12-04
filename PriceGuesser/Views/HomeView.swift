import SwiftUI

struct HomeView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(GameRouter.self) private var router
    @Environment(AppSettings.self) private var settings
    @State private var showSettings = false

    var body: some View {
        NavigationStack(path: Bindable(router).path) {
            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 16) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color("brandPrimary"))
                        .cornerRadius(10.0)
                        .shadow(color: Color("brandPrimary").opacity(0.3), radius: 12, x: 0, y: 6)
                        .accessibilityLabel("PriceGuesser logo")

                    Text("home.title".localized)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("home.subtitle".localized)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                Spacer()

                VStack(spacing: 20) {
                    Button {
                        HapticManager.impact(style: .medium)
                        router.navigate(to: .setup)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.title3)
                            Text("home.startGame".localized)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color("brandPrimary"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color("brandPrimary").opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .accessibilityLabel("Start a new game")
                    .accessibilityHint("Double tap to begin setting up a new price guessing game")

                    Button {
                        HapticManager.impact(style: .light)
                        router.navigate(to: .tutorial)
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title3)
                            Text("home.tutorial".localized)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color("cardBackground"))
                        .foregroundColor(Color("brandPrimary"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("brandPrimary"), lineWidth: 2)
                        )
                    }
                    .accessibilityLabel("Tutorial")
                    .accessibilityHint("Learn how to play PriceGuesser")

                    Button {
                        HapticManager.impact(style: .light)
                        router.navigate(to: .history)
                    } label: {
                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.title3)
                            Text("home.history".localized)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color("cardBackground"))
                        .foregroundColor(Color("brandSecondary"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("brandSecondary"), lineWidth: 2)
                        )
                    }
                    .accessibilityLabel("Game history")
                    .accessibilityHint("View past games and their results")

                    Button {
                        HapticManager.impact(style: .light)
                        router.navigate(to: .ranking)
                    } label: {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.title3)
                            Text("home.ranking".localized)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color("cardBackground"))
                        .foregroundColor(.orange)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    }
                    .accessibilityLabel("Player rankings")
                    .accessibilityHint("View top-scoring players")
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .background(Color("backgroundColor").ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.impact(style: .light)
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(Color("brandPrimary"))
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Open app settings and player management")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environment(settings)
                    .environment(dataManager)
            }
            .navigationDestination(for: GameRoute.self) { route in
                switch route {
                case .setup:
                    GameSetupView()
                        .environment(dataManager)
                        .environment(router)
                        .environment(settings)
                case let .gameplay(restaurant, players, currency, gameMode):
                    GameplayView(restaurant: restaurant, players: players, currency: currency, gameMode: gameMode)
                        .environment(dataManager)
                        .environment(router)
                        .environment(settings)
                case let .realPrice(restaurant, guesses, currency, gameMode):
                    RealPriceInputView(restaurant: restaurant, guesses: guesses, currency: currency, gameMode: gameMode)
                        .environment(dataManager)
                        .environment(router)
                case let .results(restaurant, actualPrice, results, currency, gameMode):
                    ResultsView(restaurant: restaurant, actualPrice: actualPrice, results: results, currency: currency, gameMode: gameMode)
                        .environment(dataManager)
                        .environment(router)
                case .history:
                    GameHistoryView()
                        .environment(dataManager)
                        .environment(settings)
                case .tutorial:
                    TutorialView()
                case .ranking:
                    RankingView()
                        .environment(dataManager)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    HomeView()
        .environment(DataManager.shared)
        .environment(GameRouter())
        .environment(AppSettings.shared)
}
#endif
