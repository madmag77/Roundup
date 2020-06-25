import Foundation

struct RoundupViewModel {
    let accountName: String
    let roundupAmount: String
    let savingGoalName: String
    let error: String?
    let eligibleForRoundup: Bool
    let roundupSucceeded: Bool
    let spinnerIsOn: Bool
    
    static func initState() -> RoundupViewModel {
        return RoundupViewModel(accountName: "",
        roundupAmount: "",
        savingGoalName: "",
        error: nil,
        eligibleForRoundup: false,
        roundupSucceeded: false,
        spinnerIsOn: false)
    }
    
    func startedNetworkRequest() -> RoundupViewModel {
        return RoundupViewModel(accountName: self.accountName,
                                roundupAmount: self.roundupAmount,
                                savingGoalName: self.savingGoalName,
                                error: self.error,
                                eligibleForRoundup: self.eligibleForRoundup,
                                roundupSucceeded: self.roundupSucceeded,
                                spinnerIsOn: true)
    }
    
    func stoppedNetworkRequest() -> RoundupViewModel {
        return RoundupViewModel(accountName: self.accountName,
                                roundupAmount: self.roundupAmount,
                                savingGoalName: self.savingGoalName,
                                error: self.error,
                                eligibleForRoundup: self.eligibleForRoundup,
                                roundupSucceeded: self.roundupSucceeded,
                                spinnerIsOn: false)
    }
    
    func gotError(with description: String) -> RoundupViewModel {
        return RoundupViewModel(accountName: self.accountName,
                                roundupAmount: self.roundupAmount,
                                savingGoalName: self.savingGoalName,
                                error: description,
                                eligibleForRoundup: false,
                                roundupSucceeded: self.roundupSucceeded,
                                spinnerIsOn: self.spinnerIsOn)
    }
    
    func acquiredAccountId(_ account: String) -> RoundupViewModel {
        return RoundupViewModel(accountName: account,
                                roundupAmount: "",
                                savingGoalName: "",
                                error: nil,
                                eligibleForRoundup: self.eligibleForRoundup,
                                roundupSucceeded: self.roundupSucceeded,
                                spinnerIsOn: false)
    }
    
    func acquiredSavingGoal(with name: String) -> RoundupViewModel {
        return RoundupViewModel(accountName: self.accountName,
                                roundupAmount: self.roundupAmount,
                                savingGoalName: name,
                                error: nil,
                                eligibleForRoundup: self.eligibleForRoundup,
                                roundupSucceeded: self.roundupSucceeded,
                                spinnerIsOn: self.spinnerIsOn)
    }
    
    func calculatedRoundupAmount(_ roundAmount: String) -> RoundupViewModel {
        return RoundupViewModel(accountName: self.accountName,
                                roundupAmount: roundAmount,
                                savingGoalName: self.savingGoalName,
                                error: nil,
                                eligibleForRoundup: self.eligibleForRoundup,
                                roundupSucceeded: self.roundupSucceeded,
                                spinnerIsOn: self.spinnerIsOn)
    }
    
    func eligibleForTransaction() -> RoundupViewModel {
        return RoundupViewModel(accountName: self.accountName,
                                roundupAmount: self.roundupAmount,
                                savingGoalName: self.savingGoalName,
                                error: nil,
                                eligibleForRoundup: true,
                                roundupSucceeded: self.roundupSucceeded,
                                spinnerIsOn: self.spinnerIsOn)
    }
    
    func transactionSucceeded() -> RoundupViewModel {
        return RoundupViewModel(accountName: self.accountName,
                                roundupAmount: self.roundupAmount,
                                savingGoalName: self.savingGoalName,
                                error: nil,
                                eligibleForRoundup: false,
                                roundupSucceeded: true,
                                spinnerIsOn: self.spinnerIsOn)
    }
}
