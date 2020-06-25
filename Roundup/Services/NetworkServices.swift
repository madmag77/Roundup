import Foundation

func getAccounts(transport: RestTransport) -> (@escaping (Response<[Account]>) -> ()) -> () {
    return { callback in
            transport.get(endpoint: "accounts", transform: { (accountsResponse: AccountsResponse) in accountsResponse.accounts }, callback: callback)
        }
}

func getTransactions(transport: RestTransport) -> (String, String, Date, @escaping (Response<[Transaction]>) -> ()) -> () {
    return {accountUid, categoryUid, changeSince, callback in
        transport.get(endpoint: "feed/account/\(accountUid)/category/\(categoryUid)?changesSince=\(changeSince.iso8601)", transform: { (transactions: TransactionResponse) in transactions.feedItems }, callback: callback)
    }
}

func getSavingGoals(transport: RestTransport) -> (String, @escaping (Response<[SavingGoal]>) -> ()) -> () {
    return { accountUid, callback in
        transport.get(endpoint: "account/\(accountUid)/savings-goals", transform: { (goals: SavingGoalResponse) in goals.savingsGoalList }, callback: callback)
    }
}

func makeRoundupTransaction(transport: RestTransport) -> (String, String, String, Int64, @escaping (Response<Int>) -> ()) -> () {
    return {accountUid, savingGoalUid, currency, amount, callback in
        let roundupAmount = AmountRequest(amount: Amount(currency: currency, minorUnits: amount))
        let jsonData = try! JSONEncoder().encode(roundupAmount)

        transport.put(endpoint: "account/\(accountUid)/savings-goals/\(savingGoalUid)/add-money/\(UUID().uuidString)", body: jsonData, callback: callback)
    }
}
