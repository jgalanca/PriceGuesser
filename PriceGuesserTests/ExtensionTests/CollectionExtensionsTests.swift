import XCTest
@testable import PriceGuesser

@MainActor
final class CollectionExtensionsTests: XCTestCase {
    
    // MARK: - Player Array Extensions
    
    func testSortedByName() {
        // Given
        let players = [
            Player(name: "Charlie"),
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        
        // When
        let sorted = players.sortedByName()
        
        // Then
        XCTAssertEqual(sorted[0].name, "Alice")
        XCTAssertEqual(sorted[1].name, "Bob")
        XCTAssertEqual(sorted[2].name, "Charlie")
    }
    
    func testSortedByNameCaseInsensitive() {
        // Given
        let players = [
            Player(name: "alice"),
            Player(name: "CHARLIE"),
            Player(name: "Bob")
        ]
        
        // When
        let sorted = players.sortedByName()
        
        // Then
        XCTAssertEqual(sorted[0].name, "alice")
        XCTAssertEqual(sorted[1].name, "Bob")
        XCTAssertEqual(sorted[2].name, "CHARLIE")
    }
    
    func testSortedByNameEmptyArray() {
        // Given
        let players: [Player] = []
        
        // When
        let sorted = players.sortedByName()
        
        // Then
        XCTAssertTrue(sorted.isEmpty)
    }
    
    // MARK: - Game Array Extensions
    
    func testSortedByDate() {
        // Given
        let oldDate = Date(timeIntervalSince1970: 1000)
        let newDate = Date(timeIntervalSince1970: 2000)
        let middleDate = Date(timeIntervalSince1970: 1500)
        
        let games = [
            Game(restaurant: Restaurant(name: "Old"), datePlayed: oldDate, participants: [], actualPrice: 50, results: [], currencyCode: "USD", gameMode: .closest),
            Game(restaurant: Restaurant(name: "New"), datePlayed: newDate, participants: [], actualPrice: 50, results: [], currencyCode: "USD", gameMode: .closest),
            Game(restaurant: Restaurant(name: "Middle"), datePlayed: middleDate, participants: [], actualPrice: 50, results: [], currencyCode: "USD", gameMode: .closest)
        ]
        
        // When
        let sorted = games.sortedByDate()
        
        // Then
        XCTAssertEqual(sorted[0].restaurant.name, "New")
        XCTAssertEqual(sorted[1].restaurant.name, "Middle")
        XCTAssertEqual(sorted[2].restaurant.name, "Old")
    }
    
    func testFilteredByPlayer() {
        // Given
        let playerId = UUID()
        let otherPlayerId = UUID()
        
        let games = [
            Game(
                restaurant: Restaurant(name: "Game 1"),
                participants: [PlayerGuess(playerId: playerId, playerName: "Alice", guessedPrice: 50)],
                actualPrice: 50,
                results: [GameResult(playerId: playerId, playerName: "Alice", guessedPrice: 50, actualPrice: 50, points: 10, rank: 1)],
                currencyCode: "USD",
                gameMode: .closest
            ),
            Game(
                restaurant: Restaurant(name: "Game 2"),
                participants: [PlayerGuess(playerId: otherPlayerId, playerName: "Bob", guessedPrice: 50)],
                actualPrice: 50,
                results: [GameResult(playerId: otherPlayerId, playerName: "Bob", guessedPrice: 50, actualPrice: 50, points: 10, rank: 1)],
                currencyCode: "USD",
                gameMode: .closest
            ),
            Game(
                restaurant: Restaurant(name: "Game 3"),
                participants: [PlayerGuess(playerId: playerId, playerName: "Alice", guessedPrice: 50)],
                actualPrice: 50,
                results: [GameResult(playerId: playerId, playerName: "Alice", guessedPrice: 50, actualPrice: 50, points: 10, rank: 1)],
                currencyCode: "USD",
                gameMode: .closest
            )
        ]
        
        // When
        let filtered = games.filteredByPlayer(playerId)
        
        // Then
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0].restaurant.name, "Game 1")
        XCTAssertEqual(filtered[1].restaurant.name, "Game 3")
    }
    
    func testFilteredByPlayerNoMatches() {
        // Given
        let otherPlayerId = UUID()
        let games = [
            Game(
                restaurant: Restaurant(name: "Game 1"),
                participants: [PlayerGuess(playerId: otherPlayerId, playerName: "Other", guessedPrice: 50)],
                actualPrice: 50,
                results: [],
                currencyCode: "USD",
                gameMode: .closest
            )
        ]
        
        // When
        let filtered = games.filteredByPlayer(UUID())
        
        // Then
        XCTAssertTrue(filtered.isEmpty)
    }
    
    func testPlayerStats() {
        // Given
        let playerId = UUID()
        
        let results = [
            GameResult(playerId: playerId, playerName: "Alice", guessedPrice: 50, actualPrice: 50, points: 10, rank: 1),
            GameResult(playerId: UUID(), playerName: "Bob", guessedPrice: 40, actualPrice: 50, points: 5, rank: 2),
            GameResult(playerId: playerId, playerName: "Alice", guessedPrice: 55, actualPrice: 60, points: 8, rank: 1),
            GameResult(playerId: UUID(), playerName: "Bob", guessedPrice: 70, actualPrice: 60, points: 6, rank: 2)
        ]
        
        // When
        let allStats = results.playerStats()
        let stats = allStats[playerId]
        
        // Then
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats?.totalGames, 2)
        XCTAssertEqual(stats?.totalPoints, 18)
        XCTAssertEqual(stats?.averagePoints, 9.0)
        XCTAssertEqual(stats?.wins, 2)
    }
    
    func testPlayerStatsNoGames() {
        // Given
        let results: [GameResult] = []
        let playerId = UUID()
        
        // When
        let allStats = results.playerStats()
        let stats = allStats[playerId]
        
        // Then
        XCTAssertNil(stats)
    }
    
    func testPlayerStatsCalculations() {
        // Given
        let playerId = UUID()
        
        let results = [
            GameResult(playerId: playerId, playerName: "Player", guessedPrice: 50, actualPrice: 50, points: 10, rank: 1),
            GameResult(playerId: playerId, playerName: "Player", guessedPrice: 70, actualPrice: 60, points: 5, rank: 2),
            GameResult(playerId: playerId, playerName: "Player", guessedPrice: 72, actualPrice: 70, points: 6, rank: 2)
        ]
        
        // When
        let allStats = results.playerStats()
        let stats = allStats[playerId]
        
        // Then
        XCTAssertEqual(stats?.totalGames, 3)
        XCTAssertEqual(stats?.totalPoints, 21)
        XCTAssertEqual(stats?.averagePoints, 7.0)
        XCTAssertEqual(stats?.wins, 1)
    }
}
