import UIKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }

    func viewDidLoad()
    func logoutButtonTouched()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileImageService: ProfileImageServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let logoutService: LogoutServiceProtocol
    
    private var profileImageServiceObserver: NSObjectProtocol?

    init(
        profileImageService: ProfileImageServiceProtocol,
        profileService: ProfileServiceProtocol,
        logoutService: LogoutServiceProtocol
    ) {
        self.profileImageService = profileImageService
        self.profileService = profileService
        self.logoutService = logoutService
    }

    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        self.updateAvatar()

        view?.setNameLabel(profileService.profile?.firstName)
        view?.setNicknameLabel(profileService.profile?.loginName)
        view?.setDescriptionLabel(profileService.profile?.bio)
    }

    func logoutButtonTouched() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        alert.addAction(
            UIAlertAction(title: "Да", style: .cancel) { [weak self] _ in
                self?.logoutService.logout()
                self?.switchToSplash()
            }
        )

        view?.showAlert(alert)
    }

    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL),
            let urlWithCorrectSizes = changeImageSize(
                in: url,
                width: 70,
                height: 70
            )
        else {
            return
        }

        view?.setAvatarImage(from: urlWithCorrectSizes)
    }

    private func switchToSplash() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }

    private func changeImageSize(in url: URL, width: Int, height: Int) -> URL? {
        guard
            var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: true
            )
        else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "w", value: String(width)),
            URLQueryItem(name: "h", value: String(height)),
        ]
        guard let updatedUrl = components.url else {
            return url
        }

        return updatedUrl
    }
}
