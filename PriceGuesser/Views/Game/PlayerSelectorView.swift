import SwiftUI

struct PlayerSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager

    @Binding var selectedPlayers: Set<UUID>
    @State private var searchText = ""
    @State private var editingPlayer: Player?
    @State private var showDeleteConfirmation = false
    @State private var playerToDelete: Player?
    @State private var addPlayerIsPresented = false

    var filteredPlayers: [Player] {
        if searchText.isEmpty {
            return dataManager.players
        }
        return dataManager.players.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                if dataManager.players.isEmpty {
                    ContentUnavailableView(
                        "players.empty".localized,
                        systemImage: "person.2.slash",
                        description: Text("players.emptyDescription".localized)
                    )
                } else {
                    ForEach(filteredPlayers) { player in
                        Button {
                            togglePlayer(player.id)
                        } label: {
                            HStack {
                                Image(systemName: selectedPlayers.contains(player.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(selectedPlayers.contains(player.id) ? Color("brandPrimary") : .gray)

                                Text(player.name)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deletePlayer(player)
                            } label: {
                                Label("common.delete".localized, systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                editPlayer(player)
                            } label: {
                                Label("common.edit".localized, systemImage: "pencil")
                            }
                            .tint(Color("AccentColor"))
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "players.search".localized)
            .navigationTitle("setup.selectPlayers".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        HapticManager.impact(style: .light)
                        dismiss()
                    } label: {
                        Text("common.done".localized)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("brandPrimary"))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.impact(style: .light)
                        addPlayerIsPresented = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("brandPrimary"))
                    }
                }
            }
            .sheet(isPresented: $addPlayerIsPresented) {
                AddPlayerView()
                    .environment(dataManager)
            }
            .sheet(item: $editingPlayer) { player in
                EditPlayerView(player: player)
                    .environment(dataManager)
            }
            .alert("players.deleteConfirmation".localized, isPresented: $showDeleteConfirmation) {
                Button("common.cancel".localized, role: .cancel) { }
                Button("common.delete".localized, role: .destructive) {
                    if let player = playerToDelete {
                        confirmDelete(player)
                    }
                }
            } message: {
                if let player = playerToDelete {
                    Text("players.deleteMessage".localized + " \(player.name)?")
                }
            }
        }
    }

    private func togglePlayer(_ id: UUID) {
        HapticManager.selection()
        if selectedPlayers.contains(id) {
            selectedPlayers.remove(id)
        } else {
            selectedPlayers.insert(id)
        }
    }

    private func editPlayer(_ player: Player) {
        HapticManager.impact(style: .light)
        editingPlayer = player
    }

    private func deletePlayer(_ player: Player) {
        HapticManager.impact(style: .light)
        playerToDelete = player
        showDeleteConfirmation = true
    }

    private func confirmDelete(_ player: Player) {
        selectedPlayers.remove(player.id)
        dataManager.deletePlayer(player)
        HapticManager.notification(type: .success)
        playerToDelete = nil
    }
}

#if DEBUG
#Preview {
    PlayerSelectorView(selectedPlayers: .constant([]))
        .environment(DataManager.shared)
}
#endif
