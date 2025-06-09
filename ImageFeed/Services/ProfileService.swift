import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case requestIsAlreadyRunning
}

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()

    private(set) var profile: Profile?

    private let currentUserInfoPath = "me"
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?

    private init() {
        ProfileLogoutService.shared.register(sessionInfoStorage: self)
    }

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        guard currentTask == nil else {
            print(
                "[ProfileService] fetchProfile: request is already running, failing this one to prevent race conditions"
            )
            completion(.failure(ProfileServiceError.requestIsAlreadyRunning))
            return
        }

        guard let request = makeGetProfileRequest(with: token) else {
            print("[ProfileService] fetchProfile: can't create request")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<GetProfileResponse, Error>) in

            switch result {
            case .success(let dto):
                let domain = dto.toDomain()
                self?.profile = domain
                completion(.success(domain))
            case .failure(let error):
                print("[ProfileService] fetchProfile: \(error)")
                completion(.failure(error))
            }

            self?.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }

    private func makeGetProfileRequest(with token: String?) -> URLRequest? {
        guard let token = token, !token.isEmpty else {
            return nil
        }

        let url = URL(string: Constants.Unsplash.defaultBaseURL)?
            .appendingPathComponent(currentUserInfoPath)
        guard let url = url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.addAccessToken(token)
        request.httpMethod = Constants.HTTPMethod.get.rawValue
        return request
    }
}

extension ProfileService: SessionInfoStorage {
    func resetSessionInfo() {
        currentTask?.cancel()
        currentTask = nil
        profile = nil
    }
}

// MARK: - Domain

struct Profile {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    var name: String? {
        "\(firstName) \(lastName ?? "")"
    }
    var loginName: String {
        "@\(username)"
    }
}

extension GetProfileResponse {
    func toDomain() -> Profile {
        .init(
            username: username,
            firstName: firstName,
            lastName: lastName,
            bio: bio
        )
    }
}

// MARK: - DTO

struct GetProfileResponse: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
