import SwiftUI

struct ManageGroupsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager

    @State private var showAddGroup = false
    @State private var editingGroup: Group?
    @State private var showDeleteConfirmation = false
    @State private var groupToDelete: Group?

    var body: some View {
        NavigationStack {
            List {
                if dataManager.groups.isEmpty {
                    ContentUnavailableView(
                        "groups.empty".localized,
                        systemImage: "person.3",
                        description: Text("groups.emptyDescription".localized)
                    )
                } else {
                    ForEach(dataManager.groups) { group in
                        GroupRow(group: group, dataManager: dataManager)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingGroup = group
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteGroup(group)
                                } label: {
                                    Label("common.delete".localized, systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    editingGroup = group
                                } label: {
                                    Label("common.edit".localized, systemImage: "pencil")
                                }
                                .tint(Color("AccentColor"))
                            }
                    }
                }
            }
            .navigationTitle("groups.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        HapticManager.impact(style: .light)
                        dismiss()
                    } label: {
                        Text("common.close".localized)
                            .foregroundColor(Color("brandPrimary"))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.impact(style: .light)
                        showAddGroup = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("brandPrimary"))
                    }
                }
            }
            .sheet(isPresented: $showAddGroup) {
                AddGroupView()
                    .environment(dataManager)
            }
            .sheet(item: $editingGroup) { group in
                EditGroupView(group: group)
                    .environment(dataManager)
            }
            .alert("groups.deleteConfirmation".localized, isPresented: $showDeleteConfirmation) {
                Button("common.cancel".localized, role: .cancel) { }
                Button("common.delete".localized, role: .destructive) {
                    if let group = groupToDelete {
                        confirmDelete(group)
                    }
                }
            } message: {
                if let group = groupToDelete {
                    Text("groups.deleteMessage".localized + " \(group.name)?")
                }
            }
        }
    }

    private func deleteGroup(_ group: Group) {
        HapticManager.impact(style: .light)
        groupToDelete = group
        showDeleteConfirmation = true
    }

    private func confirmDelete(_ group: Group) {
        dataManager.deleteGroup(group)
        HapticManager.notification(type: .success)
        groupToDelete = nil
    }
}

struct GroupRow: View {
    let group: Group
    let dataManager: DataManager

    var players: [Player] {
        dataManager.getPlayers(for: group)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(Color("brandPrimary"))
                Text(group.name)
                    .font(.headline)
            }

            if players.isEmpty {
                Text("groups.noPlayers".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(players.map { $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview {
    ManageGroupsView()
        .environment(DataManager.shared)
}
#endif
