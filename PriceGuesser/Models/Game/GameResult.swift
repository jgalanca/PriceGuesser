import Foundation

struct GameResult: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    let guessedPrice: Double
    let actualPrice: Double
    let difference: Double
    var points: Int
    var rank: Int

    init(id: UUID = UUID(), playerId: UUID, playerName: String, guessedPrice: Double, actualPrice: Double, points: Int = 0, rank: Int = 0) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.guessedPrice = guessedPrice
        self.actualPrice = actualPrice
        self.difference = abs(guessedPrice - actualPrice)
        self.points = points
        self.rank = rank
    }
}
