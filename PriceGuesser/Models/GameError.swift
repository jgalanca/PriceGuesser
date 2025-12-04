import Foundation

enum GameError: LocalizedError {
    case noPlayersSelected
    case insufficientPlayers(minimum: Int)
    case noRestaurantSelected
    case invalidPrice
    case priceNotPositive
    case saveFailed
    case loadFailed
    case decodingFailed
    case encodingFailed
    case playerNotFound(id: UUID)
    case restaurantNotFound(id: UUID)
    case groupNotFound(id: UUID)
    case gameNotFound(id: UUID)
    case duplicatePlayerName(name: String)
    case duplicateRestaurantName(name: String)
    case duplicateGroupName(name: String)
    case custom(message: String)

    var errorDescription: String? {
        switch self {
        case .noPlayersSelected:
            return "No players selected. Please select at least one player to start the game."
        case .insufficientPlayers(let minimum):
            return "Not enough players. At least \(minimum) players are required."
        case .noRestaurantSelected:
            return "No restaurant selected. Please select a restaurant to start the game."
        case .invalidPrice:
            return "Invalid price value. Please enter a valid number."
        case .priceNotPositive:
            return "Price must be greater than zero."
        case .saveFailed:
            return "Failed to save data. Please try again."
        case .loadFailed:
            return "Failed to load data. Please restart the app."
        case .decodingFailed:
            return "Failed to read saved data. The data may be corrupted."
        case .encodingFailed:
            return "Failed to prepare data for saving."
        case .playerNotFound(let id):
            return "Player with ID \(id) not found."
        case .restaurantNotFound(let id):
            return "Restaurant with ID \(id) not found."
        case .groupNotFound(let id):
            return "Group with ID \(id) not found."
        case .gameNotFound(let id):
            return "Game with ID \(id) not found."
        case .duplicatePlayerName(let name):
            return "A player named '\(name)' already exists."
        case .duplicateRestaurantName(let name):
            return "A restaurant named '\(name)' already exists."
        case .duplicateGroupName(let name):
            return "A group named '\(name)' already exists."
        case .custom(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noPlayersSelected, .insufficientPlayers:
            return "Add more players or select existing players."
        case .noRestaurantSelected:
            return "Select a restaurant from the list or create a new one."
        case .invalidPrice, .priceNotPositive:
            return "Enter a valid positive number for the price."
        case .saveFailed, .encodingFailed:
            return "Check if you have enough storage space available."
        case .loadFailed, .decodingFailed:
            return "Try restarting the app. If the problem persists, you may need to reset the app data."
        case .duplicatePlayerName, .duplicateRestaurantName, .duplicateGroupName:
            return "Choose a different name."
        default:
            return nil
        }
    }
}
