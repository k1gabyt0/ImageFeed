import Foundation
import UIKit

final class ImagesListService {
    static let shared = ImagesListService()

    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )

    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let perPage: Int = 10

    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?

    private init() {}

    func fetchPhotosNextPage() {
        guard currentTask == nil else {
            return
        }

        let nextPage = (lastLoadedPage ?? 0) + 1
        let request = makeRequest(
            for: nextPage,
            with: OAuth2TokenStorage.shared.token
        )
        guard let request else {
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<PhotosResponse, Error>) in
            switch result {
            case .success(let dto):
                self?.photos = dto.toModel()
                self?.lastLoadedPage = nextPage

                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            case .failure(let error):
                print("[ImagesListService] fetchPhotosNextPage: \(error)")
            }

            self?.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }

    private func makeRequest(for page: Int, with token: String?)
        -> URLRequest?
    {
        guard let token else {
            return nil
        }

        var urlComponents = URLComponents(
            string: Constants.Unsplash.defaultBaseURL
        )
        urlComponents?.path = "/photos"
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
        ]
        guard let url = urlComponents?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = Constants.HTTPMethod.get.rawValue
        request.addAccessToken(token)
        return request
    }
}

// MARK: Likes

enum LikesError: Error {
    case wrongRequest
    case wrongResponse
}

extension ImagesListService {
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let request = makeRequest(
            forPhoto: photoId,
            is: isLike,
            // TODO: Передавать в функцию?
            with: OAuth2TokenStorage.shared.token
        )
        guard let request else {
            print("[ImagesListService] changeLike: can't create request")
            completion(.failure(LikesError.wrongRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<LikeResponse, Error>) in
            switch result {
            case .success:
                if let index = self?.photos.firstIndex(
                    where: { $0.id == photoId })
                {
                    self?.photos[index].isLiked = isLike
                }

                completion(.success(()))
            case .failure(let error):
                print("[ImagesListService] changeLike: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private func makeRequest(
        forPhoto id: String,
        is like: Bool,
        with token: String?
    )
        -> URLRequest?
    {
        guard let token else {
            return nil
        }

        var urlComponents = URLComponents(
            string: Constants.Unsplash.defaultBaseURL
        )
        urlComponents?.path = "/photos/\(id)/like"
        guard let url = urlComponents?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod =
            if like {
                Constants.HTTPMethod.post.rawValue
            } else {
                Constants.HTTPMethod.delete.rawValue
            }
        request.addAccessToken(token)
        return request
    }
}

extension ImagesListService {
    func reset() {
        currentTask?.cancel()
        currentTask = nil
        photos = []
    }
}

// MARK: Domain

struct Photo {
    let id: String
    let size: CGSize
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

// MARK: DTO

struct LikeResponse: Codable {
    let photo: PhotoResponse
}

typealias PhotosResponse = [PhotoResponse]

struct PhotoUrls: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResponse: Codable {
    let id: String
    let width: Int
    let height: Int
    let description: String?
    let urls: PhotoUrls
    let likedByUser: Bool?

    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case description
        case urls
        case likedByUser = "liked_by_user"
    }
}

extension PhotosResponse {
    func toModel() -> [Photo] {
        self.map {
            Photo(
                id: $0.id,
                size: CGSize(
                    width: CGFloat($0.width),
                    height: CGFloat($0.height)
                ),
                welcomeDescription: $0.description,
                thumbImageURL: $0.urls.thumb,
                largeImageURL: $0.urls.full,
                isLiked: $0.likedByUser ?? false
            )
        }
    }
}
