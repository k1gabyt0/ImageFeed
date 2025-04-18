import UIKit

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"

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
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        <#code#>
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
