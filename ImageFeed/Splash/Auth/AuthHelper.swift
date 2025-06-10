import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    private let config: AuthConfiguration

    init(config: AuthConfiguration = .standard) {
        self.config = config
    }

    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            return nil
        }

        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: config.authURLString)
        else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(
                name: "client_id",
                value: config.accessKey
            ),
            URLQueryItem(
                name: "redirect_uri",
                value: config.redirectURI
            ),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: config.accessScope),
        ]

        return urlComponents.url
    }

    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
