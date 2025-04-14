import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        guard let image = image else { return }

        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
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

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()

        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
