import UIKit

final class RoundupViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var roundupAmountTextField: UITextField!
    @IBOutlet weak var savingGoalTextField: UITextField!
    @IBOutlet weak var transferRoundupButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var roundupSucceeded: UILabel!
    
    private lazy var presenter: RoundupPresenter = {
        return AccountsPresenterBuilder.build(view: self)
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountTextField.isEnabled = false
        roundupAmountTextField.isEnabled = false
        savingGoalTextField.isEnabled = false
        
        presenter.viewDidLoad()
    }
    
    @IBAction func transferRoundButtonTap(_ sender: Any) {
        presenter.transferRoundupToSavingGoal()
    }
}

extension RoundupViewController: RoundupView {
    func updateView(with viewModel: RoundupViewModel) {
        
        if let error = viewModel.error {
            errorLabel.text = error
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        
        accountTextField.text = viewModel.accountName
        roundupAmountTextField.text = viewModel.roundupAmount
        savingGoalTextField.text = viewModel.savingGoalName
        
        transferRoundupButton.isEnabled = viewModel.eligibleForRoundup
       
        if viewModel.spinnerIsOn && !spinner.isAnimating {
            spinner.isHidden = false
            spinner.startAnimating()
        } else if !viewModel.spinnerIsOn && spinner.isAnimating {
            spinner.stopAnimating()
            spinner.isHidden = true
        }
    
        roundupSucceeded.isHidden = !viewModel.roundupSucceeded
    }
}
