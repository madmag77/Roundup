import XCTest
@testable import Roundup

class RoundupBussinessLogicTests: XCTestCase {
    func testWeekIntervalBanCase() throws {
        // Given
        let roundupBussinessLogic = RoundupBusinessLogicImpl(getAccounts: successGetAccountsMock([]),
                                                             getTransactions: successGetTransactionsMock([]),
                                                             getSavingGoals: successGetSavingGoalsMock([]),
                                                             makeRoundupTransaction: successMakeRoundupTransactionMock(),
                                                             accountLastRoundupDatestorage: lessThenAWeekStorage())
        
        // When
        var error: RoundupError? = nil
        var account: Account? = nil
        var savingGoal: SavingGoal? = nil
        var amount: Amount? = nil
        var isFinished: Bool = false
        
        roundupBussinessLogic.fetchRoundupNeededInfo { (roundupError, roundupAccount, roundupSavingGoal, roundupAmount, finished) in
            error = roundupError
            account = roundupAccount
            savingGoal = roundupSavingGoal
            amount = roundupAmount
            isFinished = finished
        }
        
        // Then
        XCTAssertEqual(error, RoundupError.lastRoundupInLessThenAWeek)
        XCTAssertNil(account)
        XCTAssertNil(savingGoal)
        XCTAssertNil(amount)
        XCTAssertTrue(isFinished)
    }
    
    func testWeekIntervalOkButNoAccountCase() throws {
        // Given
        let roundupBussinessLogic = RoundupBusinessLogicImpl(getAccounts: successGetAccountsMock([]),
                                                             getTransactions: successGetTransactionsMock([]),
                                                             getSavingGoals: successGetSavingGoalsMock([]),
                                                             makeRoundupTransaction: successMakeRoundupTransactionMock(),
                                                             accountLastRoundupDatestorage: moreThenAWeekStorage())
        
        // When
        var error: RoundupError? = nil
        var account: Account? = nil
        var savingGoal: SavingGoal? = nil
        var amount: Amount? = nil
        var isFinished: Bool = false
        
        roundupBussinessLogic.fetchRoundupNeededInfo { (roundupError, roundupAccount, roundupSavingGoal, roundupAmount, finished) in
            error = roundupError
            account = roundupAccount
            savingGoal = roundupSavingGoal
            amount = roundupAmount
            isFinished = finished
        }
        
        // Then
        XCTAssertEqual(error, RoundupError.noAccount)
        XCTAssertNil(account)
        XCTAssertNil(savingGoal)
        XCTAssertNil(amount)
        XCTAssertTrue(isFinished)
    }
    
    func testAccountOkButNoSavingGoalCase() throws {
        // Given
        let expectedAccount = Account(accountUid: "2", currency: "GBP", defaultCategory: "11")
        let roundupBussinessLogic = RoundupBusinessLogicImpl(getAccounts: successGetAccountsMock([expectedAccount]),
                                                             getTransactions: successGetTransactionsMock([]),
                                                             getSavingGoals: successGetSavingGoalsMock([]),
                                                             makeRoundupTransaction: successMakeRoundupTransactionMock(),
                                                             accountLastRoundupDatestorage: moreThenAWeekStorage())
        
        // When
        var error: RoundupError? = nil
        var account: Account? = nil
        var savingGoal: SavingGoal? = nil
        var amount: Amount? = nil
        var isFinished: Bool = false
        
        roundupBussinessLogic.fetchRoundupNeededInfo { (roundupError, roundupAccount, roundupSavingGoal, roundupAmount, finished) in
            error = roundupError
            account = roundupAccount
            savingGoal = roundupSavingGoal
            amount = roundupAmount
            isFinished = finished
        }
        
        // Then
        XCTAssertEqual(error, RoundupError.noSavingGoal)
        XCTAssertEqual(account, expectedAccount)
        XCTAssertNil(savingGoal)
        XCTAssertNil(amount)
        XCTAssertTrue(isFinished)
    }
    
    func testNoTransactionsCase() throws {
        // Given
        let expectedAccount = Account(accountUid: "2", currency: "GBP", defaultCategory: "11")
        let expectedSavingGoal = SavingGoal(savingsGoalUid: "1", name: "expectedSavingGoal")
        let roundupBussinessLogic = RoundupBusinessLogicImpl(getAccounts: successGetAccountsMock([expectedAccount]),
                                                             getTransactions: successGetTransactionsMock([]),
                                                             getSavingGoals: successGetSavingGoalsMock([expectedSavingGoal]),
                                                             makeRoundupTransaction: successMakeRoundupTransactionMock(),
                                                             accountLastRoundupDatestorage: moreThenAWeekStorage())
        
        // When
        var error: RoundupError? = nil
        var account: Account? = nil
        var savingGoal: SavingGoal? = nil
        var amount: Amount? = nil
        var isFinished: Bool = false
        
        roundupBussinessLogic.fetchRoundupNeededInfo { (roundupError, roundupAccount, roundupSavingGoal, roundupAmount, finished) in
            error = roundupError
            account = roundupAccount
            savingGoal = roundupSavingGoal
            amount = roundupAmount
            isFinished = finished
        }
        
        // Then
        XCTAssertEqual(error, RoundupError.noTransactions)
        XCTAssertEqual(account, expectedAccount)
        XCTAssertEqual(savingGoal, expectedSavingGoal)
        XCTAssertNil(amount)
        XCTAssertTrue(isFinished)
    }
    
    // TODO: add other test cases

}

// Mocks

fileprivate func successGetAccountsMock(_ accountsToReturn: [Account]) -> (@escaping (Response<[Account]>) -> ()) -> () {
    return { (callback) in
        callback(.success(accountsToReturn))
    }
}

fileprivate func successGetTransactionsMock(_ transactionsToReturn: [Transaction]) -> (String, String, Date, @escaping (Response<[Transaction]>) -> ()) -> () {
    return { (accountId, categoryId, date, callback) in
        callback(.success(transactionsToReturn))
    }
}

fileprivate func successGetSavingGoalsMock(_ savingGoals: [SavingGoal]) -> (String, @escaping (Response<[SavingGoal]>) -> ()) -> () {
    return { (accountId, callback) in
        callback(.success(savingGoals))
    }
}

fileprivate func successMakeRoundupTransactionMock() -> (String, String, String, Int64, @escaping (Response<Int>) -> ()) -> () {
    return { (accountId, savingGoalId, currency, amoutn, callback) in
        callback(.success(200))
    }
}

fileprivate func lessThenAWeekStorage() -> AccountDateStorage {
    let mock = AccountDateStorageMock()
    mock.lastRoundupDate = Date()
    return mock
}

fileprivate func moreThenAWeekStorage() -> AccountDateStorage {
    let mock = AccountDateStorageMock()
    mock.lastRoundupDate = Date().toDateWeekAgo().toDateWeekAgo()
    return mock
}

fileprivate final class AccountDateStorageMock: AccountDateStorage {
    var lastRoundupDate: Date?
}
