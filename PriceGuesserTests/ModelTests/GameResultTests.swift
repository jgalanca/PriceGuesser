import XCTest
@testable import PriceGuesser

@MainActor
final class GameResultTests: XCTestCase {
    
    func testGameResultInitialization() {
        // Given
        let playerId = UUID()
        
        // When
        let result = GameResult(
            playerId: playerId,
            playerName: "Test Player",
            guessedPrice: 50.0,
            actualPrice: 55.0,
            points: 8,
            rank: 1
        )
        
        // Then
        XCTAssertEqual(result.playerId, playerId)
        XCTAssertEqual(result.playerName, "Test Player")
        XCTAssertEqual(result.guessedPrice, 50.0)
        XCTAssertEqual(result.actualPrice, 55.0)
        XCTAssertEqual(result.points, 8)
        XCTAssertEqual(result.rank, 1)
    }
    
    func testDifferenceCalculation() {
        // Given
        let resultOver = GameResult(
            playerId: UUID(),
            playerName: "Player 1",
            guessedPrice: 60.0,
            actualPrice: 55.0,
            points: 6,
            rank: 2
        )
        
        let resultUnder = GameResult(
            playerId: UUID(),
            playerName: "Player 2",
            guessedPrice: 50.0,
            actualPrice: 55.0,
            points: 8,
            rank: 1
        )
        
        // Then - difference is always positive (absolute value)
        XCTAssertEqual(resultOver.difference, 5.0)
        XCTAssertEqual(resultUnder.difference, 5.0)
    }
    
    func testExactGuess() {
        // Given
        let result = GameResult(
            playerId: UUID(),
            playerName: "Perfect Player",
            guessedPrice: 55.0,
            actualPrice: 55.0,
            points: 10,
            rank: 1
        )
        
        // Then
        XCTAssertEqual(result.difference, 0.0)
    }
    
    func testGameResultEquality() {
        // Given
        let id = UUID()
        let playerId = UUID()
        let result1 = GameResult(
            id: id,
            playerId: playerId,
            playerName: "Player",
            guessedPrice: 50.0,
            actualPrice: 55.0,
            points: 8,
            rank: 1
        )
        let result2 = GameResult(
            id: id,
            playerId: playerId,
            playerName: "Player",
            guessedPrice: 50.0,
            actualPrice: 55.0,
            points: 8,
            rank: 1
        )
        
        // Then
        XCTAssertEqual(result1, result2)
    }
    
    func testGameResultCodable() throws {
        // Given
        let result = GameResult(
            playerId: UUID(),
            playerName: "Test Player",
            guessedPrice: 50.0,
            actualPrice: 55.0,
            points: 8,
            rank: 1
        )
        
        // When
        let encoded = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(GameResult.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.playerName, result.playerName)
        XCTAssertEqual(decoded.guessedPrice, result.guessedPrice)
        XCTAssertEqual(decoded.actualPrice, result.actualPrice)
        XCTAssertEqual(decoded.points, result.points)
        XCTAssertEqual(decoded.rank, result.rank)
    }
}
