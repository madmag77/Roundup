import Foundation

struct Transaction: Codable, Equatable {
    let feedItemUid: String
    let amount: Amount
    let sourceAmount: Amount // TODO - find out how it related to amount
    let source: TransactionSource
    let status: TransactionStatus
}

struct TransactionResponse: Codable {
    let feedItems: [Transaction]
}
