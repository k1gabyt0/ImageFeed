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

final class ViewControllerSpy: ProfileViewControllerProtocol {
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
