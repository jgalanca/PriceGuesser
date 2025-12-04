import Foundation

struct PlayerGuess: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    var guessedPrice: Double

    init(id: UUID = UUID(), playerId: UUID, playerName: String, guessedPrice: Double) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.guessedPrice = guessedPrice
    }
}
