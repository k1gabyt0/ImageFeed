import UIKit

final class SplashViewController: UIViewController {
    private let authStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    private var logoImageView: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let token = authStorage.token else {
            showAuthFlow()
            return
        }

        fetchProfile(token)
    }

    private func showMainFlow() {
        guard let window = UIApplication.shared.windows.first else {
            print("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }

    private func showAuthFlow() {
        let authController =
            UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController
        guard let authController = authController else {
            return
        }

        authController.delegate = self

        let navigationViewController =
            UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(
                withIdentifier: "NavigationViewController"
            ) as? UINavigationController
        guard let navigationViewController = navigationViewController else {
            return
        }

        navigationViewController.viewControllers = [authController]

        navigationViewController.modalPresentationStyle = .fullScreen
        present(navigationViewController, animated: true)
    }

    private func setupUI() {
        view.backgroundColor = .ypBlack

        logoImageView = UIImageView(
            image: UIImage(resource: .logo)
        )

        let logoImageViewConstraints = setupLogoImage()

        NSLayoutConstraint.activate(
            logoImageViewConstraints
        )
    }

    private func setupLogoImage() -> [NSLayoutConstraint] {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        return [
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ]
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        guard let token = self.authStorage.token else {
            return
        }

        fetchProfile(token)
    }

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                profileImageService
                    .fetchProfileImageURL(for: profile.username, with: token) {
                        _ in
                    }
                self.showMainFlow()
            case .failure:
                break
            }
        }
    }
}
