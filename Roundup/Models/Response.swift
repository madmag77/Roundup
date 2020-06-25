import Foundation

enum BackendError: Equatable {
    case clientError(ClientError)
    case serverError
    case noNetwork
}

enum Response<T> {
    case success(T)
    case error(BackendError)
}
