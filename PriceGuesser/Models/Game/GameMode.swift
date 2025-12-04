import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case closest
    case underOnly

    var id: String { rawValue }

    var name: String {
        switch self {
        case .closest:
            return "gameMode.closest.name".localized
        case .underOnly:
            return "gameMode.underOnly.name".localized
        }
    }

    var description: String {
        switch self {
        case .closest:
            return "gameMode.closest.description".localized
        case .underOnly:
            return "gameMode.underOnly.description".localized
        }
    }

    var icon: String {
        switch self {
        case .closest:
            return "target"
        case .underOnly:
            return "arrow.down.to.line"
        }
    }
}
