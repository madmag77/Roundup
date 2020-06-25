import XCTest
@testable import Roundup

class RoundupCalculatorTests: XCTestCase {
    let transactions =  [
        Transaction(feedItemUid: "1",
                    amount: Amount(currency: "GBP", minorUnits: 101),
                    sourceAmount: Amount(currency: "GBP", minorUnits: 101),
                    source: .CASH_DEPOSIT,
                    status: .SETTLED),
        
        Transaction(feedItemUid: "2",
                    amount: Amount(currency: "GBP", minorUnits: 199),
                    sourceAmount: Amount(currency: "GBP", minorUnits: 199),
                    source: .CASH_DEPOSIT,
                    status: .SETTLED)
    ]
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCalculateRoundupSimpleCase() throws {
        // Given
        let simpleTransactions = transactions
        let expectedAmount = Amount(currency: "GBP", minorUnits: 100)
        
        // When
        let amount = RoundupCalculator.calculateRoundup(from: simpleTransactions)
        
        // Then
        XCTAssertEqual(amount, expectedAmount)
    }
    
    func testCalculateRoundupZeroCase() throws {
        // Given
        let zeroRransaction = [
            Transaction(feedItemUid: "3",
            amount: Amount(currency: "GBP", minorUnits: 200),
            sourceAmount: Amount(currency: "GBP", minorUnits: 200),
            source: .CASH_DEPOSIT,
            status: .SETTLED)
        ]
        let expectedAmount = Amount(currency: "GBP", minorUnits: 0)
        
        // When
        let amount = RoundupCalculator.calculateRoundup(from: zeroRransaction)
        
        // Then
        XCTAssertEqual(amount, expectedAmount)
    }
    
    func testCalculateExceptSettledAndInternalCase() throws {
        // Given
        let transactionsWithNotEligibleSourceAndStatus = transactions + [
            Transaction(feedItemUid: "3",
                        amount: Amount(currency: "GBP", minorUnits: 210),
                        sourceAmount: Amount(currency: "GBP", minorUnits: 210),
                        source: .INTERNAL_TRANSFER,
                        status: .SETTLED),
            Transaction(feedItemUid: "4",
                        amount: Amount(currency: "GBP", minorUnits: 330),
                        sourceAmount: Amount(currency: "GBP", minorUnits: 330),
                        source: .CHEQUE,
                        status: .REFUNDED)
        ]
        let expectedAmount = Amount(currency: "GBP", minorUnits: 100)
        
        // When
        let amount = RoundupCalculator.calculateRoundup(from: transactionsWithNotEligibleSourceAndStatus)
        
        // Then
        XCTAssertEqual(amount, expectedAmount)
    }
}
