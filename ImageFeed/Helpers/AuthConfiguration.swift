import Foundation

enum Constants {
    enum Unsplash {
        static let accessKey = "74tWGCJJC0sDy4trDUb2PWAc0NxgBGUCABZUUo8u2Eg"
        static let secretKey = "IAd3EB6aY8Y1RKhAeX2Gs5l0-tr3wPoes-K1_60A1CU"
        static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"

        static let accessScope = "public+read_user+write_likes"
        static let defaultBaseURL = "https://api.unsplash.com"
        static let authorizeURL = "https://unsplash.com/oauth/authorize"
        static let tokenURL = "https://unsplash.com/oauth/token"

        enum GrantType {
            static let authorizationCode = "authorization_code"
        }
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    enum HTTPHeader: String {
        case authorization = "Authorization"
    }
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        authURLString: String,
        defaultBaseURL: URL
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: "74tWGCJJC0sDy4trDUb2PWAc0NxgBGUCABZUUo8u2Eg",
            secretKey: "IAd3EB6aY8Y1RKhAeX2Gs5l0-tr3wPoes-K1_60A1CU",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!
        )
    }
}
