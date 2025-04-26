import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()

    private let tokenKey = "auth_token"

    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }

    private init() {}
}
