import XCTest
@testable import PriceGuesser

@MainActor
final class PlayerTests: XCTestCase {
    
    func testPlayerInitialization() {
        // Given/When
        let player = Player(name: "John Doe")
        
        // Then
        XCTAssertEqual(player.name, "John Doe")
        XCTAssertNotNil(player.id)
    }
    
    func testPlayerWithCustomId() {
        // Given
        let customId = UUID()
        
        // When
        let player = Player(id: customId, name: "Jane Doe")
        
        // Then
        XCTAssertEqual(player.id, customId)
        XCTAssertEqual(player.name, "Jane Doe")
    }
    
    func testPlayerEquality() {
        // Given
        let id = UUID()
        let dateCreated = Date()
        let player1 = Player(id: id, name: "John", dateCreated: dateCreated)
        let player2 = Player(id: id, name: "John", dateCreated: dateCreated)
        
        // Then
        XCTAssertEqual(player1, player2)
    }
    
    func testPlayerInequalityDifferentIds() {
        // Given
        let player1 = Player(name: "John")
        let player2 = Player(name: "John")
        
        // Then
        XCTAssertNotEqual(player1, player2)
    }
    
    func testPlayerCodable() throws {
        // Given
        let player = Player(name: "Test Player")
        
        // When
        let encoded = try JSONEncoder().encode(player)
        let decoded = try JSONDecoder().decode(Player.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.id, player.id)
        XCTAssertEqual(decoded.name, player.name)
    }
    
    func testPlayerHashable() {
        // Given
        let player1 = Player(name: "Alice")
        let player2 = Player(name: "Bob")
        let player3 = player1
        
        var playerSet = Set<Player>()
        
        // When
        playerSet.insert(player1)
        playerSet.insert(player2)
        playerSet.insert(player3)
        
        // Then
        XCTAssertEqual(playerSet.count, 2)
        XCTAssertTrue(playerSet.contains(player1))
        XCTAssertTrue(playerSet.contains(player2))
    }
}
