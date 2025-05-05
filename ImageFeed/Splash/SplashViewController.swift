import UIKit

final class SplashViewController: UIViewController {
    private let authStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    private let showAuthFlowSegueId = "ShowAuthFlow"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let token = authStorage.token else {
            performSegue(withIdentifier: showAuthFlowSegueId, sender: nil)
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
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        guard let token = self.authStorage.token else {
            return
        }

        fetchProfile(token)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthFlowSegueId {
            guard
                let navigationController = segue.destination
                    as? UINavigationController,
                let viewController = navigationController.viewControllers.first
                    as? AuthViewController
            else {
                print("Failed to prepare segue for \(showAuthFlowSegueId)")
                return
            }

            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Не удалось получить профиль",
                    message: "Ошибка: \(error.localizedDescription)",
                    preferredStyle: .alert
                )
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
}
