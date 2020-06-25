import Foundation

struct AccountsPresenterBuilder {
    static func build(view: RoundupViewController) -> RoundupPresenter {
        let transport = RestTransportImpl()
        return RoundupPresenter(
            roundupBusinessLogic: RoundupBusinessLogicImpl(getAccounts: getAccounts(transport: transport),
                                                           getTransactions: getTransactions(transport: transport),
                                                           getSavingGoals: getSavingGoals(transport: transport),
                                                           makeRoundupTransaction: makeRoundupTransaction(transport: transport),
                                                           accountLastRoundupDatestorage: UserDefaults.standard),
            view: view)
    }
}
