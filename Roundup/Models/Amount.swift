import Foundation

struct Amount: Codable, Equatable {
    let currency: String
    let minorUnits: Int64
}

struct AmountRequest: Codable {
    let amount: Amount
}
