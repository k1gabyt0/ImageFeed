import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()

    private(set) var profile: Profile?

    private let currentUserInfoPath = "me"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private init() {}

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        task?.cancel()

        guard let request = makeGetProfileRequest(with: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                switch GetProfileResponse.decode(from: data) {
                case .success(let dto):
                    let domain = dto.toDomain()
                    self?.profile = domain
                    completion(.success(domain))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }

            self?.task = nil
        }
        self.task = task
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

// MARK: - Domain

struct Profile {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?

    var name: String {
        "\(firstName) \(lastName)"
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
    let lastName: String
    let bio: String?

    static func decode(from data: Data) -> Result<GetProfileResponse, Error> {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let response = try decoder.decode(
                GetProfileResponse.self,
                from: data
            )
            return .success(response)
        } catch {
            print("Error: decode error")
            return .failure(error)
        }
    }
}
