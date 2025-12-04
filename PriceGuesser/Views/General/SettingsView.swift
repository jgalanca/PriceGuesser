import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @Environment(DataManager.self) private var dataManager

    @State private var showManageGroups = false
    @State private var showAddPlayer = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("settings.currency".localized, selection: Bindable(settings).selectedCurrency) {
                        ForEach(Currency.allCurrencies) { currency in
                            HStack {
                                Text("\(currency.name) (\(currency.symbol))")
                            }
                            .tag(currency)
                        }
                    }
                    .accessibilityLabel("Currency selection")
                    .accessibilityHint("Choose default currency for new games")
                } header: {
                    Text("settings.currencySection".localized)
                } footer: {
                    Text("settings.currencyFooter".localized)
                }

                Section {
                    Picker("settings.language".localized, selection: Bindable(settings).selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    }
                    .accessibilityLabel("Language selection")
                    .accessibilityHint("Choose app language")
                } header: {
                    Text("settings.languageSection".localized)
                } footer: {
                    Text("settings.languageFooter".localized)
                }

                Section {
                    Picker("settings.appearance".localized, selection: Bindable(settings).selectedAppearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.displayName)
                                .tag(mode)
                        }
                    }
                    .accessibilityLabel("Appearance mode selection")
                    .accessibilityHint("Choose light, dark, or system appearance")
                } header: {
                    Text("settings.appearanceSection".localized)
                } footer: {
                    Text("settings.appearanceFooter".localized)
                }

                Section {
                    Button {
                        HapticManager.impact(style: .light)
                        showAddPlayer = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(Color("brandPrimary"))
                            Text("players.add".localized)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityLabel("Add new player")
                    .accessibilityHint("Opens form to create a new player")

                    Button {
                        HapticManager.impact(style: .light)
                        showManageGroups = true
                    } label: {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(Color("brandPrimary"))
                            Text("groups.manage".localized)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityLabel("Manage player groups")
                    .accessibilityHint("Opens group management screen")
                } header: {
                    Text("settings.playersSection".localized)
                } footer: {
                    Text("settings.playersFooter".localized)
                }

                Section {
                    HStack {
                        Text("settings.version".localized)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(AppVersion.fullVersion)
                            .foregroundColor(.primary)
                    }
                    .font(.footnote)
                } header: {
                    Text("settings.aboutSection".localized)
                }
            }
            .sheet(isPresented: $showAddPlayer) {
                AddPlayerView()
                    .environment(dataManager)
            }
            .sheet(isPresented: $showManageGroups) {
                ManageGroupsView()
                    .environment(dataManager)
            }
            .navigationTitle("settings.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.impact(style: .light)
                        dismiss()
                    } label: {
                        Text("common.done".localized)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("brandPrimary"))
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .environment(AppSettings.shared)
        .environment(DataManager.shared)
}
#endif
