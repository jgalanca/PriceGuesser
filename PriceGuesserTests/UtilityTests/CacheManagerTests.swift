import XCTest
@testable import PriceGuesser

@MainActor
final class CacheManagerTests: XCTestCase {
    
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
        cacheManager.clearAll()
    }
    
    override func tearDown() {
        cacheManager.clearAll()
        super.tearDown()
    }
    
    // MARK: - Basic Operations
    
    func testSetAndGetString() {
        // Given
        let key = CacheKey.lastSync
        let value = "2024-01-01"
        
        // When
        cacheManager.set(value, forKey: key)
        let retrieved: String? = cacheManager.get(forKey: key)
        
        // Then
        XCTAssertEqual(retrieved, value)
    }
    
    func testSetAndGetInt() {
        // Given
        let key = CacheKey.lastSync
        let value = 42
        
        // When
        cacheManager.set(value, forKey: key)
        let retrieved: Int? = cacheManager.get(forKey: key)
        
        // Then
        XCTAssertEqual(retrieved, value)
    }
    
    func testSetAndGetArray() {
        // Given
        let key = CacheKey.players
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        
        // When
        cacheManager.set(players, forKey: key)
        let retrieved: [Player]? = cacheManager.get(forKey: key)
        
        // Then
        XCTAssertEqual(retrieved?.count, players.count)
        XCTAssertEqual(retrieved?[0].name, "Alice")
        XCTAssertEqual(retrieved?[1].name, "Bob")
    }
    
    func testGetNonExistentKey() {
        // Given
        let key = CacheKey.groups
        
        // When
        let retrieved: String? = cacheManager.get(forKey: key)
        
        // Then
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Remove Operations
    
    func testRemoveKey() {
        // Given
        let key = CacheKey.restaurants
        cacheManager.set("value", forKey: key)
        
        // When
        cacheManager.remove(forKey: key)
        let retrieved: String? = cacheManager.get(forKey: key)
        
        // Then
        XCTAssertNil(retrieved)
    }
    
    func testClearAll() {
        // Given
        let key1 = CacheKey.players
        let key2 = CacheKey.restaurants
        cacheManager.set("value1", forKey: key1)
        cacheManager.set("value2", forKey: key2)
        
        // When
        cacheManager.clearAll()
        let retrieved1: String? = cacheManager.get(forKey: key1)
        let retrieved2: String? = cacheManager.get(forKey: key2)
        
        // Then
        XCTAssertNil(retrieved1)
        XCTAssertNil(retrieved2)
    }
    
    // MARK: - Overwrite Operations
    
    func testOverwriteValue() {
        // Given
        let key = CacheKey.gameHistory
        cacheManager.set("original", forKey: key)
        
        // When
        cacheManager.set("updated", forKey: key)
        let retrieved: String? = cacheManager.get(forKey: key)
        
        // Then
        XCTAssertEqual(retrieved, "updated")
    }
    
    // MARK: - Type Safety
    
    func testTypeMismatch() {
        // Given
        let key = CacheKey.lastSync
        cacheManager.set("string value", forKey: key)
        
        // When - Try to retrieve as wrong type
        let retrieved: Int? = cacheManager.get(forKey: key)
        
        // Then
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Predefined Keys
    
    func testPredefinedKeysPlayers() {
        // Given
        let players = [Player(name: "Test Player")]
        
        // When
        cacheManager.set(players, forKey: .players)
        let retrieved: [Player]? = cacheManager.get(forKey: .players)
        
        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.count, 1)
    }
    
    func testPredefinedKeysGameHistory() {
        // Given
        let games = [
            Game(
                restaurant: Restaurant(name: "Test"),
                participants: [],
                actualPrice: 50.0,
                results: [],
                currencyCode: "USD",
                gameMode: .closest
            )
        ]
        
        // When
        cacheManager.set(games, forKey: .gameHistory)
        let retrieved: [Game]? = cacheManager.get(forKey: .gameHistory)
        
        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.count, 1)
    }
}
