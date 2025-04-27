import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButton()
    }

    private func configureBackButton() {
        let backwardImage = UIImage(named: Constants.Images.backward)

        navigationController?.navigationBar.backIndicatorImage = backwardImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage =
            backwardImage
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        vc.dismiss(animated: true)

        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let token):
                self.oauth2TokenStorage.token = token
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print(error)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webView = segue.destination as? WebViewViewController
            else {
                print("destination is not WebViewViewController")
                return
            }

            webView.delegate = self
        }

        super.prepare(for: segue, sender: sender)
    }
}
