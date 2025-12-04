import SwiftUI

// MARK: - Restaurant Info Section
struct RestaurantInfoSection: View {
    @Binding var restaurantName: String
    @Binding var googleMapsLink: String
    @Binding var selectedCurrency: Currency
    @Binding var selectedGameMode: GameMode

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("setup.title".localized)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // Restaurant Name
            VStack(alignment: .leading, spacing: 8) {
                Text("setup.restaurantName".localized)
                    .font(.headline)
                    .foregroundColor(.secondary)

                TextField("setup.restaurantNamePlaceholder".localized, text: $restaurantName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color("cardBackground"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }

            // Google Maps Link
            VStack(alignment: .leading, spacing: 8) {
                Text("setup.googleMapsLink".localized)
                    .font(.headline)
                    .foregroundColor(.secondary)

                TextField("setup.googleMapsLinkPlaceholder".localized, text: $googleMapsLink)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color("cardBackground"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            CurrencySelector(selectedCurrency: $selectedCurrency)
            GameModeSelector(selectedGameMode: $selectedGameMode)
        }
    }
}

// MARK: - Currency Selector
struct CurrencySelector: View {
    @Binding var selectedCurrency: Currency

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("setup.currency".localized)
                .font(.headline)
                .foregroundColor(.secondary)

            Menu {
                ForEach(Currency.allCurrencies) { currency in
                    Button {
                        selectedCurrency = currency
                        HapticManager.selection()
                    } label: {
                        HStack {
                            Text(currency.symbol)
                            Text(currency.name)
                            Text("(\(currency.code))")
                            if selectedCurrency.code == currency.code {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedCurrency.symbol)
                        .font(.title3)
                        .foregroundColor(.primary)
                    Text(selectedCurrency.name)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color("cardBackground"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Game Mode Selector
struct GameModeSelector: View {
    @Binding var selectedGameMode: GameMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("setup.gameMode".localized)
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                ForEach(GameMode.allCases) { mode in
                    Button {
                        selectedGameMode = mode
                        HapticManager.selection()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: mode.icon)
                                .font(.title3)
                                .foregroundColor(selectedGameMode == mode ? Color("brandPrimary") : .secondary)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.name)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text(mode.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedGameMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(Color("brandPrimary"))
                            } else {
                                Image(systemName: "circle")
                                    .font(.title3)
                                    .foregroundColor(.secondary.opacity(0.3))
                            }
                        }
                        .padding()
                        .background(selectedGameMode == mode ? Color("brandPrimary").opacity(0.1) : Color("cardBackground"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedGameMode == mode ? Color("brandPrimary") : Color.gray.opacity(0.2),
                                    lineWidth: selectedGameMode == mode ? 2 : 1
                                )
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Player Selection Section
struct PlayerSelectionSection: View {
    @Environment(DataManager.self) private var dataManager

    @Binding var selectedPlayers: Set<UUID>
    @Binding var selectedGroupId: UUID?
    @Binding var showPlayerSelector: Bool
    @Binding var showAddGroup: Bool

    let toggleGroupSelection: (Group) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("setup.selectPlayers".localized)
                .font(.headline)
                .foregroundColor(.secondary)

            if !dataManager.groups.isEmpty {
                GroupSelectionList(
                    selectedGroupId: $selectedGroupId,
                    showAddGroup: $showAddGroup,
                    toggleGroupSelection: toggleGroupSelection
                )

                SectionDivider()
            } else {
                CreateGroupPrompt(showAddGroup: $showAddGroup)
                SectionDivider()
            }

            IndividualPlayerSelectionButton(
                selectedPlayers: $selectedPlayers,
                selectedGroupId: $selectedGroupId,
                showPlayerSelector: $showPlayerSelector
            )
        }
    }
}

// MARK: - Group Selection List
struct GroupSelectionList: View {
    @Environment(DataManager.self) private var dataManager

    @Binding var selectedGroupId: UUID?
    @Binding var showAddGroup: Bool

    let toggleGroupSelection: (Group) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(dataManager.groups) { group in
                let isSelected = selectedGroupId == group.id
                Button {
                    toggleGroupSelection(group)
                } label: {
                    GameSetupGroupRow(group: group, isSelected: isSelected)
                }
            }

            // Create New Group Button
            Button {
                HapticManager.impact(style: .light)
                showAddGroup = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color("brandPrimary"))

                    Text("groups.createNew".localized)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("brandPrimary"))

                    Spacer()
                }
                .padding()
                .background(Color("cardBackground"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("brandPrimary").opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Group Row
struct GameSetupGroupRow: View {
    @Environment(DataManager.self) private var dataManager
    let group: Group
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "person.3.fill")
                .font(.title2)
                .foregroundColor(isSelected ? Color("brandPrimary") : Color("brandPrimary").opacity(0.7))

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                let players = dataManager.getPlayers(for: group)
                if !players.isEmpty {
                    Text("\(players.count) " + "players.count".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brandPrimary"))
            }
        }
        .padding()
        .background(isSelected ? Color("brandPrimary").opacity(0.1) : Color("cardBackground"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color("brandPrimary") : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
    }
}

// MARK: - Create Group Prompt
struct CreateGroupPrompt: View {
    @Binding var showAddGroup: Bool

    var body: some View {
        Button {
            HapticManager.impact(style: .light)
            showAddGroup = true
        } label: {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.title2)
                    .foregroundColor(Color("brandPrimary"))

                VStack(alignment: .leading, spacing: 4) {
                    Text("groups.create".localized)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("groups.createDescription".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("brandPrimary"))
            }
            .padding()
            .background(Color("cardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Section Divider
struct SectionDivider: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
            Text("common.or".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Individual Player Selection Button
struct IndividualPlayerSelectionButton: View {
    @Binding var selectedPlayers: Set<UUID>
    @Binding var selectedGroupId: UUID?
    @Binding var showPlayerSelector: Bool

    var body: some View {
        Button {
            HapticManager.impact(style: .light)
            showPlayerSelector = true
        } label: {
            HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.title2)
                    .foregroundColor(selectedGroupId != nil ? Color("brandSecondary").opacity(0.3) : Color("brandSecondary"))

                VStack(alignment: .leading, spacing: 4) {
                    Text("setup.selectIndividually".localized)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedGroupId != nil ? .secondary : .primary)

                    if selectedGroupId != nil {
                        Text("setup.deselectGroupFirst".localized)
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else if selectedPlayers.isEmpty {
                        Text("setup.noPlayersSelected".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(selectedPlayers.count) " + "setup.playersSelected".localized)
                            .font(.caption)
                            .foregroundColor(Color("brandPrimary"))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color("cardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedGroupId != nil ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(selectedGroupId != nil)
    }
}
