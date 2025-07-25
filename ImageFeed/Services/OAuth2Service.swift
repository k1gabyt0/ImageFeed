import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var currentCode: String?

    private let config: AuthConfiguration
    
    private init(config: AuthConfiguration = .standard) {
        self.config = config
    }

    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard currentCode != code else {
            print("[Oauth2Service] fetchOAuthToken: code already requested")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        currentCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[Oauth2Service] fetchOAuthToken: can't create request for code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseBody, Error>) in

            switch result {
            case .success(let dto):
                completion(.success(dto.accessToken))
            case .failure(let error):
                print("[Oauth2Service] fetchOAuthToken: \(error)")
                completion(.failure(error))
            }

            self?.task = nil
            self?.currentCode = nil
        }
        self.task = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents(string: config.tokenURLString)
        urlComponents?.queryItems = [
            URLQueryItem(
                name: "client_id",
                value: config.accessKey
            ),
            URLQueryItem(
                name: "client_secret",
                value: config.secretKey
            ),
            URLQueryItem(
                name: "redirect_uri",
                value: config.redirectURI
            ),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(
                name: "grant_type",
                value: AuthConfiguration.GrantType.authorizationCode
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

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
