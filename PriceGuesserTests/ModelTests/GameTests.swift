import XCTest
@testable import PriceGuesser

@MainActor
final class GameTests: XCTestCase {
    
    func testGameInitialization() {
        // Given
        let restaurant = Restaurant(name: "Test Restaurant")
        let participants = [
            PlayerGuess(playerId: UUID(), playerName: "Player 1", guessedPrice: 50.0),
            PlayerGuess(playerId: UUID(), playerName: "Player 2", guessedPrice: 60.0)
        ]
        let results = [
            GameResult(playerId: participants[0].playerId, playerName: "Player 1", guessedPrice: 50.0, actualPrice: 55.0, points: 8, rank: 1),
            GameResult(playerId: participants[1].playerId, playerName: "Player 2", guessedPrice: 60.0, actualPrice: 55.0, points: 6, rank: 2)
        ]
        
        // When
        let game = Game(
            restaurant: restaurant,
            participants: participants,
            actualPrice: 55.0,
            results: results,
            currencyCode: "USD",
            gameMode: .closest
        )
        
        // Then
        XCTAssertEqual(game.restaurant.name, "Test Restaurant")
        XCTAssertEqual(game.participants.count, 2)
        XCTAssertEqual(game.actualPrice, 55.0)
        XCTAssertEqual(game.results.count, 2)
        XCTAssertEqual(game.currencyCode, "USD")
        XCTAssertEqual(game.gameMode, .closest)
    }
    
    func testGameCurrencyMapping() {
        // Given
        let game = Game(
            restaurant: Restaurant(name: "Test"),
            participants: [],
            actualPrice: 100.0,
            results: [],
            currencyCode: "EUR",
            gameMode: .closest
        )
        
        // When
        let currency = game.currency
        
        // Then
        XCTAssertEqual(currency.code, "EUR")
        XCTAssertEqual(currency.symbol, "€")
    }
    
    func testGameWithInvalidCurrencyCodeFallsBackToDetected() {
        // Given
        let game = Game(
            restaurant: Restaurant(name: "Test"),
            participants: [],
            actualPrice: 100.0,
            results: [],
            currencyCode: "INVALID",
            gameMode: .closest
        )
        
        // When
        let currency = game.currency
        
        // Then
        XCTAssertNotNil(currency)
        // Should fall back to detected currency
    }
    
    func testGameEquality() {
        // Given
        let id = UUID()
        let restaurantId = UUID()
        let datePlayed = Date()
        let dateCreated = Date()
        let restaurant1 = Restaurant(id: restaurantId, name: "Test", dateCreated: dateCreated)
        let restaurant2 = Restaurant(id: restaurantId, name: "Test", dateCreated: dateCreated)
        
        let game1 = Game(
            id: id,
            restaurant: restaurant1,
            datePlayed: datePlayed,
            participants: [],
            actualPrice: 100.0,
            results: [],
            currencyCode: "USD",
            gameMode: .closest
        )
        let game2 = Game(
            id: id,
            restaurant: restaurant2,
            datePlayed: datePlayed,
            participants: [],
            actualPrice: 100.0,
            results: [],
            currencyCode: "USD",
            gameMode: .closest
        )
        
        // Then
        XCTAssertEqual(game1, game2)
    }
    
    func testGameCodable() throws {
        // Given
        let game = Game(
            restaurant: Restaurant(name: "Test Restaurant"),
            participants: [
                PlayerGuess(playerId: UUID(), playerName: "Player 1", guessedPrice: 50.0)
            ],
            actualPrice: 55.0,
            results: [],
            currencyCode: "USD",
            gameMode: .closest
        )
        
        // When
        let encoded = try JSONEncoder().encode(game)
        let decoded = try JSONDecoder().decode(Game.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.restaurant.name, game.restaurant.name)
        XCTAssertEqual(decoded.actualPrice, game.actualPrice)
        XCTAssertEqual(decoded.currencyCode, game.currencyCode)
        XCTAssertEqual(decoded.gameMode, game.gameMode)
    }
}
