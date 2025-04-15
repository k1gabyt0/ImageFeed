import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!

    private let minScale = 0.1
    private let maxScale = 1.25
    private var fullScreenScale: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale

        guard let image = image else { return }

        imageView.image = image
        imageView.frame.size = image.size
        view.layoutIfNeeded()

        fullScreenScale = calculateScaleFor(image: image)
        rescaleAndCenterImageInScrollView()
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }

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

    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
        if scale >= fullScreenScale {
            return
        }

        // Откатываемся по красоте на дефолтный масштаб если отдалили картинку далеко
        rescaleAndCenterImageInScrollView(animated: true)
    }
}
