import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?

    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
