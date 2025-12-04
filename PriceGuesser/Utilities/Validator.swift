import Foundation

struct ValidationResult {
    let isValid: Bool
    let error: GameError?

    static var valid: ValidationResult {
        ValidationResult(isValid: true, error: nil)
    }

    static func invalid(_ error: GameError) -> ValidationResult {
        ValidationResult(isValid: false, error: error)
    }
}

enum Validator {
    static func validatePlayerName(_ name: String, existingPlayers: [Player], excludingId: UUID? = nil) -> ValidationResult {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            return .invalid(.custom(message: "Player name cannot be empty"))
        }

        let isDuplicate = existingPlayers.contains { player in
            player.name.lowercased() == trimmedName.lowercased() && player.id != excludingId
        }

        if isDuplicate {
            return .invalid(.duplicatePlayerName(name: trimmedName))
        }

        return .valid
    }

    static func validateRestaurantName(_ name: String, existingRestaurants: [Restaurant], excludingId: UUID? = nil) -> ValidationResult {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            return .invalid(.custom(message: "Restaurant name cannot be empty"))
        }

        let isDuplicate = existingRestaurants.contains { restaurant in
            restaurant.name.lowercased() == trimmedName.lowercased() && restaurant.id != excludingId
        }

        if isDuplicate {
            return .invalid(.duplicateRestaurantName(name: trimmedName))
        }

        return .valid
    }

    static func validateGroupName(_ name: String, existingGroups: [Group], excludingId: UUID? = nil) -> ValidationResult {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            return .invalid(.custom(message: "Group name cannot be empty"))
        }

        let isDuplicate = existingGroups.contains { group in
            group.name.lowercased() == trimmedName.lowercased() && group.id != excludingId
        }

        if isDuplicate {
            return .invalid(.duplicateGroupName(name: trimmedName))
        }

        return .valid
    }

    static func validatePrice(_ price: Double) -> ValidationResult {
        guard price > 0 else {
            return .invalid(.priceNotPositive)
        }

        guard price.isFinite else {
            return .invalid(.invalidPrice)
        }

        return .valid
    }

    static func validateGameSetup(players: [Player], restaurant: Restaurant?) -> ValidationResult {
        if players.isEmpty {
            return .invalid(.noPlayersSelected)
        }

        if players.count < 2 {
            return .invalid(.insufficientPlayers(minimum: 2))
        }

        if restaurant == nil {
            return .invalid(.noRestaurantSelected)
        }

        return .valid
    }
}
