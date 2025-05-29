import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()

    private let tokenKey = "auth_token"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue = newValue else { return }

            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }

    private init() {
        ProfileLogoutService.shared.register(sessionInfoStorage: self)
    }
}

extension OAuth2TokenStorage: SessionInfoStorage {
    func resetSessionInfo() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
