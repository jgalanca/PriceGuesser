import Foundation
import SwiftUI

@MainActor
@Observable
class AppSettings {
    static let shared = AppSettings()

    private let currencyKey = "selectedCurrency"
    private let languageKey = "selectedLanguage"
    private let appearanceKey = "selectedAppearance"

    var selectedCurrency: Currency {
        didSet {
            saveCurrency()
        }
    }

    var selectedLanguage: AppLanguage {
        didSet {
            saveLanguage()
            applyLanguage()
        }
    }

    var selectedAppearance: AppearanceMode {
        didSet {
            saveAppearance()
        }
    }

    private init() {
        // Load currency
        if let savedCode = UserDefaults.standard.string(forKey: currencyKey),
           let currency = Currency.allCurrencies.first(where: { $0.code == savedCode }) {
            self.selectedCurrency = currency
        } else {
            self.selectedCurrency = Currency.detectFromLocale()
        }

        // Load language
        if let savedLanguageCode = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage.allCases.first(where: { $0.code == savedLanguageCode }) {
            self.selectedLanguage = language
        } else {
            self.selectedLanguage = AppLanguage.detectFromLocale()
        }

        // Load appearance
        if let savedAppearance = UserDefaults.standard.string(forKey: appearanceKey),
           let appearance = AppearanceMode(rawValue: savedAppearance) {
            self.selectedAppearance = appearance
        } else {
            self.selectedAppearance = .system
        }
    }

    private func saveCurrency() {
        UserDefaults.standard.set(selectedCurrency.code, forKey: currencyKey)
    }

    private func saveLanguage() {
        UserDefaults.standard.set(selectedLanguage.code, forKey: languageKey)
    }

    private func applyLanguage() {
        UserDefaults.standard.set([selectedLanguage.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    private func saveAppearance() {
        UserDefaults.standard.set(selectedAppearance.rawValue, forKey: appearanceKey)
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "settings.appearance.system".localized
        case .light:
            return "settings.appearance.light".localized
        case .dark:
            return "settings.appearance.dark".localized
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct Currency: Identifiable, Hashable, Codable, Sendable {
    var id = UUID()
    let code: String
    let symbol: String
    let name: String

    static let allCurrencies: [Currency] = [
        Currency(code: "USD", symbol: "$", name: "US Dollar"),
        Currency(code: "EUR", symbol: "€", name: "Euro"),
        Currency(code: "GBP", symbol: "£", name: "British Pound"),
        Currency(code: "JPY", symbol: "¥", name: "Japanese Yen"),
        Currency(code: "CNY", symbol: "¥", name: "Chinese Yuan"),
        Currency(code: "MXN", symbol: "$", name: "Mexican Peso"),
        Currency(code: "CAD", symbol: "$", name: "Canadian Dollar"),
        Currency(code: "AUD", symbol: "$", name: "Australian Dollar"),
        Currency(code: "CHF", symbol: "Fr", name: "Swiss Franc"),
        Currency(code: "ARS", symbol: "$", name: "Argentine Peso"),
        Currency(code: "BRL", symbol: "R$", name: "Brazilian Real"),
        Currency(code: "CLP", symbol: "$", name: "Chilean Peso"),
        Currency(code: "COP", symbol: "$", name: "Colombian Peso"),
        Currency(code: "PEN", symbol: "S/", name: "Peruvian Sol"),
        Currency(code: "INR", symbol: "₹", name: "Indian Rupee"),
        Currency(code: "KRW", symbol: "₩", name: "South Korean Won"),
        Currency(code: "RUB", symbol: "₽", name: "Russian Ruble"),
        Currency(code: "SEK", symbol: "kr", name: "Swedish Krona"),
        Currency(code: "NOK", symbol: "kr", name: "Norwegian Krone"),
        Currency(code: "DKK", symbol: "kr", name: "Danish Krone")
    ]

    static func detectFromLocale() -> Currency {
        let locale = Locale.current
        let currencyCode = locale.currency?.identifier ?? "USD"

        if let currency = allCurrencies.first(where: { $0.code == currencyCode }) {
            return currency
        }

        return allCurrencies.first { $0.code == "USD" }!
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    static func == (lhs: Currency, rhs: Currency) -> Bool {
        lhs.code == rhs.code
    }
}

enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    var code: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .spanish:
            return "Español"
        }
    }

    static func detectFromLocale() -> AppLanguage {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"

        if preferredLanguage.hasPrefix("es") {
            return .spanish
        }

        return .english
    }
}
