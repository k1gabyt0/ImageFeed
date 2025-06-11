import ProgressHUD
import UIKit

final class SingleImageViewController: UIViewController {
    var imageUrl: URL?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!

    private let minScale = 0.1
    private let maxScale = 1.25
    private var fullScreenScale: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale

        loadImage()
    }

    private func loadImage() {
        guard let imageUrl else {
            return
        }

        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageUrl) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let res):
                guard let self else { return }

                self.imageView.image = res.image
                self.imageView.frame.size = res.image.size
                self.fullScreenScale = self.calculateScaleFor(image: res.image)
                self.rescaleAndCenterImageInScrollView()
            case .failure:
                self?.showError()
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert
            .addAction(
                UIAlertAction(
                    title: "Не надо",
                    style: .default,
                    handler: { _ in
                        alert.dismiss(animated: true)
                    }
                )
            )
        alert
            .addAction(
                UIAlertAction(
                    title: "Повторить",
                    style: .default,
                    handler: { _ in
                        alert.dismiss(animated: true)
                        self.loadImage()
                    }
                )
            )

        present(alert, animated: true, completion: nil)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }

        let shareView = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(shareView, animated: true, completion: nil)
    }

    private func rescaleAndCenterImageInScrollView(animated: Bool = false) {
        scrollView.setZoomScale(fullScreenScale, animated: animated)
        scrollView.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.contentOffset.x = x
        scrollView.contentOffset.y = y
    }

    private func calculateScaleFor(image: UIImage) -> CGFloat {
        view.layoutIfNeeded()

        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale

        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return 1 }

        let visibleRectSize = scrollView.bounds.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height

        return min(
            maxZoomScale,
            max(minZoomScale, max(hScale, vScale))
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    // Центрируем картинку во время зума с помощью contentInset
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let newContentSize = scrollView.contentSize
        let visibleRectSize = scrollView.bounds.size

        var hInset: CGFloat = 0
        if newContentSize.width < visibleRectSize.width {
            hInset = (visibleRectSize.width - newContentSize.width) / 2
        }
        var vInset: CGFloat = 0
        if newContentSize.height < visibleRectSize.height {
            vInset = (visibleRectSize.height - newContentSize.height) / 2
        }

        scrollView.contentInset = UIEdgeInsets(
            top: vInset,
            left: hInset,
            bottom: vInset,
            right: hInset
        )
    }

    // Откатываемся по красоте на дефолтный масштаб если отдалили картинку далеко
    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
        if scale >= fullScreenScale {
            return
        }

        rescaleAndCenterImageInScrollView(animated: true)
    }
}
