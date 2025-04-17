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
