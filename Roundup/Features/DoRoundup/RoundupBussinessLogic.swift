import Foundation

enum RoundupError: Equatable {
    case lastRoundupInLessThenAWeek
    case backendError(BackendError)
    case noAccount
    case noSavingGoal
    case noTransactions
    case zeroRoundup
}

protocol RoundupBusinessLogic {
    func fetchRoundupNeededInfo(with callback: @escaping (RoundupError?, Account?, SavingGoal?, Amount?, Bool) -> ())
    func doRoundupTransaction(from account: Account, to savingGoal: SavingGoal, amount: Amount, callback: @escaping (BackendError?, Bool) -> ())
}

struct RoundupBusinessLogicImpl: RoundupBusinessLogic {
    private let getAccounts: (@escaping (Response<[Account]>) -> ()) -> ()
    private let getTransactions: (String, String, Date, @escaping (Response<[Transaction]>) -> ()) -> ()
    private let getSavingGoals: (String, @escaping (Response<[SavingGoal]>) -> ()) -> ()
    private let makeRoundupTransaction: (String, String, String, Int64, @escaping (Response<Int>) -> ()) -> ()
    private let accountLastRoundupDatestorage: AccountDateStorage

    init(getAccounts: @escaping (@escaping (Response<[Account]>) -> ()) -> (),
         getTransactions: @escaping (String, String, Date, @escaping (Response<[Transaction]>) -> ()) -> (),
         getSavingGoals: @escaping (String, @escaping (Response<[SavingGoal]>) -> ()) -> (),
         makeRoundupTransaction: @escaping (String, String, String, Int64, @escaping (Response<Int>) -> ()) -> (),
         accountLastRoundupDatestorage: AccountDateStorage) {
        
        self.getAccounts = getAccounts
        self.getTransactions = getTransactions
        self.getSavingGoals = getSavingGoals
        self.makeRoundupTransaction = makeRoundupTransaction
        self.accountLastRoundupDatestorage = accountLastRoundupDatestorage
    }
    
    func fetchRoundupNeededInfo(with callback: @escaping  (RoundupError?, Account?, SavingGoal?, Amount?, Bool) -> ()) {
        var account: Account? = nil
        var savingGoal: SavingGoal? = nil
        var amount: Amount? = nil
        
        // Initially check if one week is already passed from the last roundup
        guard hasWeekPassedSinceLastRoundup() else {
            callback(.lastRoundupInLessThenAWeek, account, savingGoal, amount, true)
            return
        }
        
        // Firstly, fetching accounts and choose the first one
        getAccounts { (response) in
            switch (response) {
                case .error(let error):
                    callback(.backendError(error), account, savingGoal, amount, true)
                    return
                case .success(let accounts):
                   if let firstAccount = accounts.first {
                        account = firstAccount
                        callback(nil, account, savingGoal, amount, false)
                   } else {
                       callback(.noAccount, account, savingGoal, amount, true)
                       return
                   }
            }
           
            guard let account = account else { fatalError("Account shouldn't be nil here") }
            
            // Secondly, fetching saving goals and again choose the first one
            self.getSavingGoals(account.accountUid) { (response) in
                switch (response) {
                    case .error(let error):
                        callback(.backendError(error), account, savingGoal, amount, true)
                        return
                    case .success(let savingGoals):
                       if let firstSavingGoal = savingGoals.first {
                            savingGoal = firstSavingGoal
                            callback(nil, account, savingGoal, amount, false)
                       } else {
                            callback(.noSavingGoal, account, savingGoal, amount, true)
                            return
                       }
                }
                
                guard let savingGoal = savingGoal else { fatalError("Saving goal shouldn't be nil here") }
                
                // Lastly, fetching transactions goals and calculate round up
                self.getTransactions(account.accountUid, account.defaultCategory, Date().toDateWeekAgo()) { (response) in
                    switch (response) {
                        case .error(let error):
                            callback(.backendError(error), account, savingGoal, amount, true)
                            return
                        case .success(let transactions):
                            if transactions.count > 0 {
                                amount = RoundupCalculator.calculateRoundup(from: transactions)
                                if let amountToApply = amount, amountToApply.minorUnits > 0 {
                                    callback(nil, account, savingGoal, amountToApply, true)
                                } else {
                                    callback(.zeroRoundup, account, savingGoal, amount, true)
                                }
                           } else {
                                callback(.noTransactions, account, savingGoal, amount, true)
                           }
                    }
                }
            }
           
        }
    }
    
    func doRoundupTransaction(from account: Account, to savingGoal: SavingGoal, amount: Amount, callback: @escaping (BackendError?, Bool) -> ()) {
        makeRoundupTransaction(account.accountUid, savingGoal.savingsGoalUid, amount.currency, amount.minorUnits) { response in
            switch (response) {
               case .error(let error):
                callback(error, false)
                return
                case .success(_):
                    
                    // In case of successfull transaction we store it's date in order to prevent making anouther roundup
                    // sooner than in a week
                    self.accountLastRoundupDatestorage.lastRoundupDate = Date().toDateOnly()
                    callback(nil, true)
            }
        }
    }
    
    private func hasWeekPassedSinceLastRoundup() -> Bool {
        let lastRoundupDate = accountLastRoundupDatestorage.lastRoundupDate ?? Date.distantPast
        return Date().toDateWeekAgo().toDateOnly() >= lastRoundupDate
    }
}
