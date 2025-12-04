import SwiftUI

struct AddPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager

    @State private var playerName = ""
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "person.badge.plus.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color("brandPrimary"))
                .padding(.top, 40)

            VStack(alignment: .leading, spacing: 8) {
                Text("players.name".localized)
                    .font(.headline)
                    .foregroundColor(.secondary)

                TextField("players.namePlaceholder".localized, text: $playerName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color("cardBackground"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .focused($isNameFieldFocused)
            }
            .padding(.horizontal, 30)

            // Save Button
            Button {
                savePlayer()
            } label: {
                Text("common.save".localized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color("brandPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(playerName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)

            Spacer()
        }
        .navigationTitle("players.add".localized)
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
        }
        .onAppear {
            isNameFieldFocused = true
        }
    }

    private func savePlayer() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let player = Player(name: trimmedName)
        dataManager.addPlayer(player)

        HapticManager.notification(type: .success)
        dismiss()
    }
}

#if DEBUG
#Preview {
    NavigationView {
        AddPlayerView()
            .environment(DataManager.shared)
    }
}
#endif
