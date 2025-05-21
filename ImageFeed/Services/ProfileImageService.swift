import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange"
    )

    private(set) var avatarURL: String?

    private let userInfoPath = "users"
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?

    private init() {}

    func fetchProfileImageURL(
        for username: String,
        with token: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        currentTask?.cancel()

        guard let request = makeRequest(with: token, for: username) else {
            print("[ProfileImageService] fetchProfileImageURL: can't create request for username: \(username)")
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

        let url = URL(string: Constants.Unsplash.defaultBaseURL)?
            .appendingPathComponent(userInfoPath)
            .appendingPathComponent(username)
        guard let url = url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.addAccessToken(token)
        request.httpMethod = Constants.HTTPMethod.get.rawValue
        return request
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
