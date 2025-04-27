import UIKit

final class SplashViewController: UIViewController {
    private let authStorage = OAuth2TokenStorage.shared

    private let showAuthFlowSegueId = "ShowAuthFlow"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard authStorage.token != nil else {
            performSegue(withIdentifier: showAuthFlowSegueId, sender: nil)
            return
        }

        showMainFlow()
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

        showMainFlow()
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
}
