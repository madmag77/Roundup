import Foundation

enum TransactionStatus: String, Codable, Equatable {
    case UPCOMING
    case PENDING
    case REVERSED
    case SETTLED
    case DECLINED
    case REFUNDED
    case RETRYING
    case ACCOUNT_CHECK
}
