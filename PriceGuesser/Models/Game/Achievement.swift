import Foundation

enum AchievementType: String, Codable, CaseIterable {
    case perfectGuess = "perfect_guess"
    case closeCall = "close_call"
    case consistentWinner = "consistent_winner"
    case comebackKid = "comeback_kid"
    case groupHost = "group_host"
    case centurion = "centurion"
    case veteran = "veteran"
    case sharpShooter = "sharp_shooter"
    case socialButterfly = "social_butterfly"
    case firstWin = "first_win"

    var title: String {
        switch self {
        case .perfectGuess:
            return "achievements.perfectGuess.title".localized
        case .closeCall:
            return "achievements.closeCall.title".localized
        case .consistentWinner:
            return "achievements.consistentWinner.title".localized
        case .comebackKid:
            return "achievements.comebackKid.title".localized
        case .groupHost:
            return "achievements.groupHost.title".localized
        case .centurion:
            return "achievements.centurion.title".localized
        case .veteran:
            return "achievements.veteran.title".localized
        case .sharpShooter:
            return "achievements.sharpShooter.title".localized
        case .socialButterfly:
            return "achievements.socialButterfly.title".localized
        case .firstWin:
            return "achievements.firstWin.title".localized
        }
    }

    var description: String {
        switch self {
        case .perfectGuess:
            return "achievements.perfectGuess.description".localized
        case .closeCall:
            return "achievements.closeCall.description".localized
        case .consistentWinner:
            return "achievements.consistentWinner.description".localized
        case .comebackKid:
            return "achievements.comebackKid.description".localized
        case .groupHost:
            return "achievements.groupHost.description".localized
        case .centurion:
            return "achievements.centurion.description".localized
        case .veteran:
            return "achievements.veteran.description".localized
        case .sharpShooter:
            return "achievements.sharpShooter.description".localized
        case .socialButterfly:
            return "achievements.socialButterfly.description".localized
        case .firstWin:
            return "achievements.firstWin.description".localized
        }
    }

    var icon: String {
        switch self {
        case .perfectGuess:
            return "🎯"
        case .closeCall:
            return "🔥"
        case .consistentWinner:
            return "👑"
        case .comebackKid:
            return "💪"
        case .groupHost:
            return "🎉"
        case .centurion:
            return "💯"
        case .veteran:
            return "⭐️"
        case .sharpShooter:
            return "🏹"
        case .socialButterfly:
            return "🦋"
        case .firstWin:
            return "🏆"
        }
    }

    var bonusPoints: Int {
        switch self {
        case .perfectGuess:
            return 5
        case .closeCall:
            return 2
        case .consistentWinner:
            return 10
        case .comebackKid:
            return 5
        case .groupHost:
            return 3
        case .centurion:
            return 50
        case .veteran:
            return 20
        case .sharpShooter:
            return 15
        case .socialButterfly:
            return 10
        case .firstWin:
            return 5
        }
    }
}

struct PlayerAchievement: Identifiable, Codable, Hashable {
    let id: UUID
    let playerId: UUID
    let type: AchievementType
    let dateEarned: Date
    let gameId: UUID?

    init(id: UUID = UUID(), playerId: UUID, type: AchievementType, dateEarned: Date = Date(), gameId: UUID? = nil) {
        self.id = id
        self.playerId = playerId
        self.type = type
        self.dateEarned = dateEarned
        self.gameId = gameId
    }
}

struct PlayerStats {
    let playerId: UUID
    let playerName: String
    var totalGames: Int
    var totalPoints: Int
    var wins: Int
    var averageDifference: Double
    var achievements: [PlayerAchievement]

    var averagePoints: Double {
        guard totalGames > 0 else { return 0 }
        return Double(totalPoints) / Double(totalGames)
    }

    var winRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(wins) / Double(totalGames) * 100
    }

    var achievementCount: Int {
        achievements.count
    }
}
