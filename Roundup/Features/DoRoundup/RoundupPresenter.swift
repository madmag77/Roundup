import Foundation

protocol RoundupView: class {
   func updateView(with viewModel: RoundupViewModel)
}

final class RoundupPresenter {
    private unowned var view: RoundupView
    private let roundupBusinessLogic: RoundupBusinessLogic
    
    private var doRoundupTransaction: () -> () = { }
   
    private lazy var viewModelUpdater: () -> (@escaping (RoundupViewModel) -> (RoundupViewModel)) -> () = {
        var viewModel: RoundupViewModel = RoundupViewModel.initState()
        return { transform in
            DispatchQueue.main.async { [weak self] in
                viewModel = transform(viewModel)
                self?.view.updateView(with: viewModel)
            }
        }
    }
    
    init(roundupBusinessLogic: RoundupBusinessLogic, view: RoundupView) {
        self.roundupBusinessLogic = roundupBusinessLogic
        self.view = view
    }
    
    func viewDidLoad() {
        fetchRoundupNeededInfo()
    }
    
    func transferRoundupToSavingGoal() {
        doRoundupTransaction()
    }
}

private extension RoundupPresenter {
    func convertBackendErrorToString(_ error: BackendError) -> String {
        switch (error) {
        case .noNetwork:
            return "No network"
        case .serverError:
           return "Internal server error. Please try again later."
        case .clientError(let clientError):
            return " Error: \(clientError.errors.first?.message ?? "Unknown error from server")"
        }
    }
    
    func updateBusinessLogicErrorToView(from error: RoundupError, updater: (@escaping (RoundupViewModel) -> (RoundupViewModel)) -> ()) {
        switch error {
        case .lastRoundupInLessThenAWeek:
            updater { $0.gotError(with: "Less than a week passed from the last roundup. Please come later. ") }
        case .backendError(let error):
            updater { $0.gotError(with: self.convertBackendErrorToString(error)) }
        case .noAccount:
             updater { $0.gotError(with: "No accounts available. Please open accound and come back.") }
        case .noSavingGoal:
            updater { $0.gotError(with: "No Saving goal available. Please create saving goal and come back.") }
        case .noTransactions:
            updater { $0.gotError(with: "No transactions have been done during last week. Nothing to roundup.") }
        case .zeroRoundup:
            updater { $0.gotError(with: "The roundup amount is equal to zero. Please make more transactions.") }
        }
    }
    
    func fetchRoundupNeededInfo() {
        let updater = viewModelUpdater()
        updater { $0.startedNetworkRequest() }
        
        roundupBusinessLogic.fetchRoundupNeededInfo { [weak self] (error, account, savingGoal, amount, finished) in
            guard let self = self else { return }
            
            if let account = account {
                updater { $0.acquiredAccountId(account.accountUid) }
            }
            
            if let savingGoal = savingGoal {
                updater { $0.acquiredSavingGoal(with: savingGoal.savingsGoalUid) }
            }
            
            if let amount = amount {
               updater { $0.calculatedRoundupAmount("\(Double(amount.minorUnits)/100.0) \(amount.currency)") }
            }
            
            if let error = error {
                self.updateBusinessLogicErrorToView(from: error, updater: updater)
            }
            
            if finished {
                updater { $0.stoppedNetworkRequest() }
                if error == nil, let account = account, let savingGoal = savingGoal, let amount = amount  {
                    updater { $0.eligibleForTransaction() }
                    self.doRoundupTransaction = { [weak self] in
                        self?.roundupBusinessLogic.doRoundupTransaction(from: account, to: savingGoal, amount: amount, callback: { [weak self] (error, success) in
                            guard let self = self else { return }
                            
                            if let error = error {
                                updater { $0.gotError(with: self.convertBackendErrorToString(error)) }
                            } else if !success {
                                updater { $0.gotError(with: "Roundup transaction failed.") }
                            } else {
                                updater { $0.transactionSucceeded() }
                            }
                        })
                    }
                }
            }
        }
    }

}
