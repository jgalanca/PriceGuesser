import Foundation

struct Game: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let restaurant: Restaurant
    let datePlayed: Date
    let participants: [PlayerGuess]
    let actualPrice: Double
    let results: [GameResult]
    let currencyCode: String
    let gameMode: GameMode

    init(id: UUID? = nil, restaurant: Restaurant, datePlayed: Date = Date(), participants: [PlayerGuess], actualPrice: Double, results: [GameResult], currencyCode: String, gameMode: GameMode = .closest) {
        // Use collision-resistant ID combining device UUID + random UUID
        // This prevents ID collisions when merging games from multiple devices
        self.id = id ?? DeviceIdentifier.generateID()
        self.restaurant = restaurant
        self.datePlayed = datePlayed
        self.participants = participants
        self.actualPrice = actualPrice
        self.results = results
        self.currencyCode = currencyCode
        self.gameMode = gameMode
    }

    var currency: Currency {
        Currency.allCurrencies.first { $0.code == currencyCode } ?? Currency.detectFromLocale()
    }
}
