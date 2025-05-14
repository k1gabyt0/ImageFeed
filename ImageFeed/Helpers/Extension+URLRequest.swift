import Foundation

extension URLRequest {
    mutating func addAccessToken(_ accessToken: String) {
        self.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: Constants.HTTPHeader.authorization.rawValue
        )
    }
}
