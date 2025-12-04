import XCTest
@testable import PriceGuesser

@MainActor
final class ValidatorTests: XCTestCase {
    
    // MARK: - Player Name Validation
    
    func testValidPlayerName() {
        // Given
        let validNames = ["John", "Alice", "Bob Smith", "María", "O'Brien"]
        let existingPlayers: [Player] = []
        
        // When/Then
        for name in validNames {
            let result = Validator.validatePlayerName(name, existingPlayers: existingPlayers)
            XCTAssertTrue(result.isValid, "'\(name)' should be valid")
            XCTAssertNil(result.error)
        }
    }
    
    func testEmptyPlayerName() {
        // When
        let result = Validator.validatePlayerName("", existingPlayers: [])
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testDuplicatePlayerName() {
        // Given
        let existingPlayers = [Player(name: "John")]
        
        // When
        let result = Validator.validatePlayerName("john", existingPlayers: existingPlayers)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testPlayerNameWhitespaceOnly() {
        // When
        let result = Validator.validatePlayerName("   ", existingPlayers: [])
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testPlayerNameWithOnlyWhitespace() {
        // When
        let result = Validator.validatePlayerName("   ", existingPlayers: [])
        
        // Then
        XCTAssertFalse(result.isValid)
    }
    
    // MARK: - Restaurant Name Validation
    
    func testValidRestaurantName() {
        // Given
        let validNames = ["Pizza Place", "Sushi Bar", "Café Rouge"]
        let existingRestaurants: [Restaurant] = []
        
        // When/Then
        for name in validNames {
            let result = Validator.validateRestaurantName(name, existingRestaurants: existingRestaurants)
            XCTAssertTrue(result.isValid, "'\(name)' should be valid")
        }
    }
    
    func testEmptyRestaurantName() {
        // When
        let result = Validator.validateRestaurantName("", existingRestaurants: [])
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testDuplicateRestaurantName() {
        // Given
        let existingRestaurants = [Restaurant(name: "Pizza Place")]
        
        // When
        let result = Validator.validateRestaurantName("pizza place", existingRestaurants: existingRestaurants)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    // MARK: - Price Validation
    
    func testValidPrice() {
        // Given
        let validPrices = [1.0, 50.5, 100.0, 999.99]
        
        // When/Then
        for price in validPrices {
            let result = Validator.validatePrice(price)
            XCTAssertTrue(result.isValid, "\(price) should be valid")
        }
    }
    
    func testZeroPrice() {
        // When
        let result = Validator.validatePrice(0.0)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testNegativePrice() {
        // When
        let result = Validator.validatePrice(-10.0)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testInfinitePrice() {
        // When
        let result = Validator.validatePrice(.infinity)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    // MARK: - Group Name Validation
    
    func testValidGroupName() {
        // Given
        let validNames = ["Friends", "Family", "Work Team"]
        let existingGroups: [Group] = []
        
        // When/Then
        for name in validNames {
            let result = Validator.validateGroupName(name, existingGroups: existingGroups)
            XCTAssertTrue(result.isValid, "'\(name)' should be valid")
        }
    }
    
    func testEmptyGroupName() {
        // When
        let result = Validator.validateGroupName("", existingGroups: [])
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testDuplicateGroupName() {
        // Given
        let existingGroups = [Group(name: "Friends", playerIds: [])]
        
        // When
        let result = Validator.validateGroupName("friends", existingGroups: existingGroups)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    // MARK: - Game Setup Validation
    
    func testValidGameSetup() {
        // Given
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let restaurant = Restaurant(name: "Test Restaurant")
        
        // When
        let result = Validator.validateGameSetup(players: players, restaurant: restaurant)
        
        // Then
        XCTAssertTrue(result.isValid)
    }
    
    func testGameSetupWithNoPlayers() {
        // Given
        let restaurant = Restaurant(name: "Test Restaurant")
        
        // When
        let result = Validator.validateGameSetup(players: [], restaurant: restaurant)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testGameSetupWithOnePlayer() {
        // Given
        let players = [Player(name: "Alice")]
        let restaurant = Restaurant(name: "Test Restaurant")
        
        // When
        let result = Validator.validateGameSetup(players: players, restaurant: restaurant)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
    
    func testGameSetupWithNoRestaurant() {
        // Given
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        
        // When
        let result = Validator.validateGameSetup(players: players, restaurant: nil)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.error)
    }
}
