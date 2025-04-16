import UIKit

private enum Constants {
    static let likeActiveImageName = "LikeActive"
    static let likeInactiveImageName = "LikeInactive"
}

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let imageNames: [String] = (0..<20).map(String.init)
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination
                    as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                return
            }

            let image = UIImage(named: imageNames[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: showSingleImageSegueIdentifier,
            sender: indexPath
        )
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let image = UIImage(named: imageNames[indexPath.row]) else {
            return 0
        }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth =
            tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        return image.size.height * scale + imageInsets.top + imageInsets.bottom
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        imageNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        guard let imageListCell = cell as? ImagesListCell else {
            // TODO Тут лучше логировать ошибку
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }

    private func configCell(for cell: ImagesListCell, with index: IndexPath) {
        let imageName = imageNames[index.row]
        guard let image = UIImage(named: imageName) else {
            return
        }

        cell.backgroundImageView.image = image
        cell.backgroundImageView.layer.cornerRadius = 16
        cell.backgroundImageView.layer.masksToBounds = true
        cell.backgroundImageView.contentMode = .scaleAspectFit

        cell.dateLabel.text = DateFormatter.russianDate.string(from: Date())

        let likeImage =
            if index.row % 2 == 0 {
                UIImage(named: Constants.likeActiveImageName)
            } else {
                UIImage(named: Constants.likeInactiveImageName)
            }
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}
