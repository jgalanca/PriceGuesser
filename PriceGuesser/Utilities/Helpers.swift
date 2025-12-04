import SwiftUI
import UIKit

enum HapticManager {
    private static var impactGenerator: UIImpactFeedbackGenerator?
    private static var currentImpactStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    private static var selectionGenerator: UISelectionFeedbackGenerator?
    private static var notificationGenerator: UINotificationFeedbackGenerator?

    static func prepare() {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        selectionGenerator = UISelectionFeedbackGenerator()
        notificationGenerator = UINotificationFeedbackGenerator()

        impactGenerator?.prepare()
        selectionGenerator?.prepare()
        notificationGenerator?.prepare()
    }

    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        if currentImpactStyle != style {
            impactGenerator = UIImpactFeedbackGenerator(style: style)
            currentImpactStyle = style
        }
        impactGenerator?.impactOccurred()
        impactGenerator?.prepare()
    }

    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator?.notificationOccurred(type)
        notificationGenerator?.prepare()
    }

    static func selection() {
        selectionGenerator?.selectionChanged()
        selectionGenerator?.prepare()
    }
}
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Currency Formatter
enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        return formatter
    }()

    static func format(_ value: Double, currency: Currency? = nil) -> String {
        let selectedCurrency = currency ?? AppSettings.shared.selectedCurrency

        if let formattedNumber = formatter.string(from: NSNumber(value: value)) {
            return "\(selectedCurrency.symbol)\(formattedNumber)"
        }
        return "\(selectedCurrency.symbol)0.00"
    }
}

// MARK: - Date Formatter Helper
enum DateFormatterHelper {
    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func format(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }

    static func formatShort(_ date: Date) -> String {
        dateOnlyFormatter.string(from: date)
    }

    static func formatRelative(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: now)

        if let days = components.day {
            switch days {
            case 0:
                return "Today"
            case 1:
                return "Yesterday"
            case 2...7:
                return "\(days) days ago"
            default:
                return formatShort(date)
            }
        }

        return formatShort(date)
    }
}
