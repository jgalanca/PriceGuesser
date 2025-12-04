import SwiftUI

struct GameSetupView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(GameRouter.self) private var router
    @Environment(AppSettings.self) private var settings

    @State private var restaurantName = ""
    @State private var googleMapsLink = ""
    @State private var selectedPlayers: Set<UUID> = []
    @State private var selectedGroupId: UUID?
    @State private var selectedCurrency: Currency
    @State private var selectedGameMode: GameMode = .closest
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var addPlayersIsPresented: Bool = false
    @State private var showPlayerSelector = false
    @State private var showAddGroup = false

    init() {
        _selectedCurrency = State(initialValue: AppSettings.shared.selectedCurrency)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Restaurant Info Section
                RestaurantInfoSection(
                    restaurantName: $restaurantName,
                    googleMapsLink: $googleMapsLink,
                    selectedCurrency: $selectedCurrency,
                    selectedGameMode: $selectedGameMode
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Players Section
                PlayerSelectionSection(
                    selectedPlayers: $selectedPlayers,
                    selectedGroupId: $selectedGroupId,
                    showPlayerSelector: $showPlayerSelector,
                    showAddGroup: $showAddGroup,
                    toggleGroupSelection: toggleGroupSelection
                )
                .padding(.horizontal, 20)

                // Start Game Button
                Button {
                    startGame()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("setup.startGame".localized)
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color("brandPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .background(Color("backgroundColor").ignoresSafeArea())
        .sheet(isPresented: $addPlayersIsPresented) {
            AddPlayerView()
                .environment(dataManager)
        }
        .sheet(isPresented: $showPlayerSelector) {
            PlayerSelectorView(selectedPlayers: $selectedPlayers)
                .environment(dataManager)
                .onDisappear {
                    // Clear group selection if individual players were modified
                    if selectedGroupId != nil {
                        selectedGroupId = nil
                    }
                }
        }
        .sheet(isPresented: $showAddGroup) {
            AddGroupView()
                .environment(dataManager)
        }
        .alert("Error", isPresented: $showError) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func startGame() {
        // Validate input
        guard !restaurantName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "setup.enterRestaurantName".localized
            showError = true
            HapticManager.notification(type: .error)
            return
        }

        guard selectedPlayers.count >= 2 else {
            errorMessage = "setup.minPlayers".localized
            showError = true
            HapticManager.notification(type: .error)
            return
        }

        // Create restaurant and get players
        let trimmedName = restaurantName.trimmingCharacters(in: .whitespaces)
        let link = googleMapsLink.trimmingCharacters(in: .whitespaces)
        let restaurant = Restaurant(
            name: trimmedName,
            googleMapsLink: link.isEmpty ? nil : link
        )
        dataManager.addRestaurant(restaurant)

        let players = dataManager.players.filter { selectedPlayers.contains($0.id) }

        HapticManager.notification(type: .success)
        router.navigate(to: .gameplay(restaurant: restaurant, players: players, currency: selectedCurrency, gameMode: selectedGameMode))
    }

    private func toggleGroupSelection(_ group: Group) {
        HapticManager.impact(style: .medium)

        if selectedGroupId == group.id {
            // Deselect the group
            selectedGroupId = nil
            selectedPlayers = []
        } else {
            // Select this group (deselect any other group and individual selections)
            selectedGroupId = group.id
            selectedPlayers = Set(group.playerIds)
        }
    }
}

#if DEBUG
#Preview {
    GameSetupView()
        .environment(DataManager.shared)
        .environment(GameRouter())
        .environment(AppSettings.shared)
}
#endif
