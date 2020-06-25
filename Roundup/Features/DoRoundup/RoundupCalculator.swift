import Foundation

struct RoundupCalculator {
    static func calculateRoundup(from transactionsList: [Transaction]) -> Amount {
        // Assumptions:
        // 1. We don't want to take into account Internal transfers (including previous roundup transfer)
        // 2. We want to take into account only finished(Settled) transactions
        // 3. In a given account all the transactions have the same currency - account currency
        return transactionsList
            .filter({$0.source != .INTERNAL_TRANSFER})
            .filter({$0.status == .SETTLED})
            .reduce(Amount(currency: "", minorUnits: 0)) { (res, transaction) -> Amount in
                let cents = transaction.amount.minorUnits % 100
                let roundup = cents == 0 ? 0 : (100 - cents)
                return Amount(currency: transaction.amount.currency, minorUnits: res.minorUnits + roundup)
        }
    }
}
