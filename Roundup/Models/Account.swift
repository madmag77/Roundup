import Foundation

struct Account: Codable, Equatable {
    let accountUid: String
    let currency: String
    let defaultCategory: String
}

struct AccountsResponse: Codable {
    let accounts: [Account]
}
