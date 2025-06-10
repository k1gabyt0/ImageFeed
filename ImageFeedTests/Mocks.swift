import Foundation
import UIKit

@testable import ImageFeed


// MARK: WebView

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {}

    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {}

    func setProgressHidden(_ isHidden: Bool) {}
}

// MARK: Profile

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String? = "http://test.domain/image.png"
}

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: ImageFeed.Profile?
}

final class LogoutServiceStub: LogoutServiceProtocol {
    func logout() {}
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: (any ImageFeed.ProfileViewControllerProtocol)?
    var viewDidLoadCalled = false
    var updateAvatarCalled = false
    var logoutButtonTouchedCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func updateAvatar() {
        updateAvatarCalled = true
    }

    func logoutButtonTouched() {
        logoutButtonTouchedCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var setAvatarImageCalled = false
    var showAlertCalled = false
    var setNameLabelCalled = false
    var setNicknameLabelCalled = false
    var setDescriptionLabelCalled = false

    func setAvatarImage(from url: URL) {
        setAvatarImageCalled = true
    }

    func showAlert(_ alert: UIAlertController) {
        showAlertCalled = true
    }

    func setNameLabel(_ text: String?) {
        setNameLabelCalled = true
    }

    func setNicknameLabel(_ text: String?) {
        setNameLabelCalled = true
    }

    func setDescriptionLabel(_ text: String?) {
        setDescriptionLabelCalled = true
    }
}

// MARK: ImagesList

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: (any ImageFeed.ImagesListViewProtocol)?

    var photos: [ImageFeed.Photo] = []
    
    var viewDidLoadCalled = false
    var imageListCellDidTapLikeCalled = false
    var loadMorePhotosCalled = false
    
    func imageListCellDidTapLike(at index: IndexPath) {
        imageListCellDidTapLikeCalled = true
    }

    func loadMorePhotos() {
        loadMorePhotosCalled = true
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

final class ImagesListViewSpy: ImagesListViewProtocol {
    var showAlertCalled = false
    var setCellLikeCalled = false
    var insertRowsCalled = false

    func showAlert(_ alert: UIAlertController) {
        showAlertCalled = true
    }

    func setCellLike(isLiked: Bool, at index: IndexPath) {
        setCellLikeCalled = true
    }

    func insertRows(at inidicies: Range<Int>) {
        insertRowsCalled = true
    }
}

final class ImagesServiceMock: ImagesListServiceProtocol {
    var photos: [ImageFeed.Photo] = []

    private let isSuccessChangingLike: Bool

    init(isSuccessChangingLike: Bool = true) {
        self.isSuccessChangingLike = isSuccessChangingLike
        fetchPhotosNextPage()
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        if isSuccessChangingLike {
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "Network Error", code: 500)))
        }
    }

    func fetchPhotosNextPage() {
        photos.append(
            Photo(
                id: "test",
                size: .zero,
                welcomeDescription: "test",
                thumbImageURL: "test",
                largeImageURL: "test",
                isLiked: false,
                createdAt: Date()
            )
        )
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self
        )
    }
}
