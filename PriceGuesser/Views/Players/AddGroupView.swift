import SwiftUI

struct AddGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager

    @State private var groupName = ""
    @State private var selectedPlayers: Set<UUID> = []
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("groups.namePlaceholder".localized, text: $groupName)
                        .focused($isNameFieldFocused)
                } header: {
                    Text("groups.name".localized)
                }

                Section {
                    if dataManager.players.isEmpty {
                        Text("players.empty".localized)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dataManager.players) { player in
                            Button {
                                togglePlayer(player.id)
                            } label: {
                                HStack {
                                    Image(systemName: selectedPlayers.contains(player.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedPlayers.contains(player.id) ? Color("brandPrimary") : .gray)
                                    Text(player.name)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("groups.selectPlayers".localized)
                } footer: {
                    Text("groups.selectPlayersFooter".localized)
                }
            }
            .navigationTitle("groups.add".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        HapticManager.impact(style: .light)
                        dismiss()
                    } label: {
                        Text("common.cancel".localized)
                            .foregroundColor(Color("brandPrimary"))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveGroup()
                    } label: {
                        Text("common.save".localized)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("brandPrimary"))
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isNameFieldFocused = true
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

    private func saveGroup() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let group = Group(
            name: trimmedName,
            playerIds: Array(selectedPlayers)
        )
        dataManager.addGroup(group)

        HapticManager.notification(type: .success)
        dismiss()
    }
}

#if DEBUG
#Preview {
    AddGroupView()
        .environment(DataManager.shared)
}
#endif
