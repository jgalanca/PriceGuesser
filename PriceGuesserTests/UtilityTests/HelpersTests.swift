import XCTest
@testable import PriceGuesser

@MainActor
final class HelpersTests: XCTestCase {
    
    // MARK: - CurrencyFormatter Tests
    
    func testCurrencyFormatterWithUSD() {
        // Given
        let currency = Currency(code: "USD", symbol: "$", name: "US Dollar")
        let amount = 42.50
        
        // When
        let formatted = CurrencyFormatter.format(amount, currency: currency)
        
        // Then
        XCTAssertTrue(formatted.contains("42"))
        XCTAssertTrue(formatted.contains("50"))
        XCTAssertTrue(formatted.contains("$"))
    }
    
    func testCurrencyFormatterWithEuro() {
        // Given
        let currency = Currency(code: "EUR", symbol: "€", name: "Euro")
        let amount = 99.99
        
        // When
        let formatted = CurrencyFormatter.format(amount, currency: currency)
        
        // Then
        XCTAssertTrue(formatted.contains("99"))
        XCTAssertTrue(formatted.contains("€"))
    }
    
    func testCurrencyFormatterWithZero() {
        // Given
        let currency = Currency(code: "USD", symbol: "$", name: "US Dollar")
        let amount = 0.0
        
        // When
        let formatted = CurrencyFormatter.format(amount, currency: currency)
        
        // Then
        XCTAssertTrue(formatted.contains("0"))
    }
    
    func testCurrencyFormatterWithLargeAmount() {
        // Given
        let currency = Currency(code: "USD", symbol: "$", name: "US Dollar")
        let amount = 1_234_567.89
        
        // When
        let formatted = CurrencyFormatter.format(amount, currency: currency)
        
        // Then
        XCTAssertNotNil(formatted)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    // MARK: - DateFormatterHelper Tests
    
    func testDateFormatterFormat() {
        // Given
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 12, day: 25))!
        
        // When
        let formatted = DateFormatterHelper.format(date)
        
        // Then
        XCTAssertTrue(formatted.contains("2024"))
        XCTAssertTrue(formatted.contains("12") || formatted.contains("Dec"))
        XCTAssertTrue(formatted.contains("25"))
    }
    
    func testDateFormatterFormatShort() {
        // Given
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 12, day: 25))!
        
        // When
        let formatted = DateFormatterHelper.formatShort(date)
        
        // Then
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains("12") || formatted.contains("Dec"))
    }
    
    func testDateFormatterCurrentDate() {
        // Given
        let now = Date()
        
        // When
        let formatted = DateFormatterHelper.format(now)
        
        // Then
        XCTAssertFalse(formatted.isEmpty)
    }
}
