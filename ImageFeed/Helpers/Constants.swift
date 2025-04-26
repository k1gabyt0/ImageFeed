import Foundation

enum Constants {
    enum Unsplash {
        static let accessKey = "74tWGCJJC0sDy4trDUb2PWAc0NxgBGUCABZUUo8u2Eg"
        static let secretKey = "IAd3EB6aY8Y1RKhAeX2Gs5l0-tr3wPoes-K1_60A1CU"
        static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"

        static let accessScope = "public+read_user+write_likes"
        static let defaultBaseURL = URL(string: "https://api.unsplash.com")
        static let authorizeURL = "https://unsplash.com/oauth/authorize"
        static let tokenURL = "https://api.unsplash.com/oauth/token"
        
        
        enum GrantType {
            static let authorizationCode = "authorization_code"
        }
    }

    enum Images {
        static let likeActiveImageName = "LikeActive"
        static let likeInactiveImageName = "LikeInactive"
        static let avatar = "Avatar"
        static let logout = "Exit"
        static let backward = "Backward"
    }
}
