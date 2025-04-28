import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Date

    static func decode(from data: Data) -> Result<OAuthTokenResponseBody, Error>
    {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let response = try decoder.decode(
                OAuthTokenResponseBody.self,
                from: data
            )
            return .success(response)
        } catch {
            print("Error: decode error")
            return .failure(error)
        }
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()

    private init() {}

    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            return
        }

        let session = URLSession.shared

        let task = session.data(for: request) { result in
            switch result {
            case .success(let data):
                switch OAuthTokenResponseBody.decode(from: data) {
                case .success(let responseBody):
                    completion(.success(responseBody.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents(string: Constants.Unsplash.tokenURL)
        urlComponents?.queryItems = [
            URLQueryItem(
                name: "client_id",
                value: Constants.Unsplash.accessKey
            ),
            URLQueryItem(
                name: "client_secret",
                value: Constants.Unsplash.secretKey
            ),
            URLQueryItem(
                name: "redirect_uri",
                value: Constants.Unsplash.redirectURI
            ),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(
                name: "grant_type",
                value: Constants.Unsplash.GrantType.authorizationCode
            ),
        ]
        guard let url = urlComponents?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = Constants.HTTPMethod.post.rawValue
        return request
    }
}
