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
        let backwardImage = UIImage(resource: .backward)

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
        /// Здесь нельзя использовать `vc.dismiss(animated: true)` потому что
        /// мы показываем `WebViewViewController` через сегвей с типом `Push` (тоесть пушим его на стек `NavigationController`), а `dismiss` применим только к вьюхам, показанным с типом `Modal`.
        /// Если мы всеже применим тут `dismiss`, то получится так что удалится сам `AuthViewController` (и создастся заново).
        vc.navigationController?.popViewController(animated: true)

        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let token):
                guard let self = self else { return }

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
