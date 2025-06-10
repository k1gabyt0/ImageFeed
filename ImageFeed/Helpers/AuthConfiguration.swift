import Foundation

enum Constants {
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
    let tokenURLString: String
    
    enum GrantType {
        static let authorizationCode = "authorization_code"
    }

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        authURLString: String,
        defaultBaseURL: URL,
        tokenURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
        self.tokenURLString = tokenURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: "74tWGCJJC0sDy4trDUb2PWAc0NxgBGUCABZUUo8u2Eg",
            secretKey: "IAd3EB6aY8Y1RKhAeX2Gs5l0-tr3wPoes-K1_60A1CU",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!,
            tokenURLString: "https://unsplash.com/oauth/token"
        )
    }
}
