import Foundation

struct ErrorDescription: Codable, Equatable {
    let message: String
}

struct ClientError: Codable, Equatable {
    let errors: [ErrorDescription]
    let success: Bool
}

struct AuthError: Codable {
    let error: String
    let errorDescription: String
}


