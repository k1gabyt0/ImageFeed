import Foundation

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService(config: .standard)
    static let didChangeNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange"
    )

    private(set) var avatarURL: String?

    private let userInfoPath = "users"
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    
    private let config: AuthConfiguration

    private init(config: AuthConfiguration) {
        self.config = config
        
        ProfileLogoutService.shared.register(sessionInfoStorage: self)
    }

    func fetchProfileImageURL(
        for username: String,
        with token: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        currentTask?.cancel()

        guard let request = makeRequest(with: token, for: username) else {
            print(
                "[ProfileImageService] fetchProfileImageURL: can't create request for username: \(username)"
            )
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<UserResultResponse, Error>) in
            switch result {
            case .success(let dto):
                let avatarUrl = dto.profileImage.small
                self?.avatarURL = avatarUrl
                completion(.success(avatarUrl))

                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarUrl]
                    )
            case .failure(let error):
                print("[ProfileImageService] fetchProfileImageURL: \(error)")
                completion(.failure(error))
            }

            self?.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }

    private func makeRequest(with token: String?, for username: String)
        -> URLRequest?
    {
        guard let token = token, !token.isEmpty else {
            return nil
        }

        let url = config.defaultBaseURL
            .appendingPathComponent(userInfoPath)
            .appendingPathComponent(username)

        var request = URLRequest(url: url)
        request.addAccessToken(token)
        request.httpMethod = Constants.HTTPMethod.get.rawValue
        return request
    }
}

extension ProfileImageService: SessionInfoStorage {
    func resetSessionInfo() {
        currentTask?.cancel()
        currentTask = nil
        avatarURL = nil
    }
}

// MARK: DTO

struct UserResultResponse: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
