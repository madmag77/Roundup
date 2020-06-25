import Foundation

struct SavingGoal: Codable, Equatable {
    let savingsGoalUid: String
    let name: String
}

struct SavingGoalResponse: Codable {
    let savingsGoalList: [SavingGoal]
}
