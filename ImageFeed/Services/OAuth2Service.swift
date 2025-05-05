import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {}

    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseBody, Error>) in

            switch result {
            case .success(let dto):
                completion(.success(dto.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }

            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
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
