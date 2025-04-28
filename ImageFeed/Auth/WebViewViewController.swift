import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )

    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!

    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self

        loadAuthWebView()
    }

    private func loadAuthWebView() {
        guard
            var urlComponents = URLComponents(
                string: Constants.Unsplash.authorizeURL
            )
        else {
            print(
                "can't construct URLComponents from string: \(Constants.Unsplash.authorizeURL)"
            )
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(
                name: "client_id",
                value: Constants.Unsplash.accessKey
            ),
            URLQueryItem(
                name: "redirect_uri",
                value: Constants.Unsplash.redirectURI
            ),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.Unsplash.accessScope),
        ]
        guard let url = urlComponents.url else {
            print("can't get URL from URLComponents")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// Progress bar
extension WebViewViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
        updateProgress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil
        )
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            decisionHandler(.cancel)
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
