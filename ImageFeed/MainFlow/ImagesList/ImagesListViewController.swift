import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func showAlert(_ alert: UIAlertController)
    func setCellLike(isLiked: Bool, at index: IndexPath)
    func insertRows(at indices: Range<Int>)
}

final class ImagesListViewController: UIViewController & ImagesListViewProtocol
{
    @IBOutlet private var tableView: UITableView?

    private var presenter: ImagesListPresenterProtocol?

    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.delegate = self
        tableView?.dataSource = self

        tableView?.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )

        presenter?.viewDidLoad()
        presenter?.loadMorePhotos()
    }

    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination
                    as? SingleImageViewController,
                let presenter,
                let indexPath = sender as? IndexPath,
                let fullImageUrl = URL(
                    string: presenter.photos[indexPath.row].largeImageURL
                )
            else {
                return
            }
            viewController.imageUrl = fullImageUrl
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }

    func setCellLike(isLiked: Bool, at index: IndexPath) {
        guard
            let cell = tableView?.cellForRow(at: index)
                as? ImagesListCell
        else {
            return
        }

        cell.setIsLiked(isLiked)
    }

    func insertRows(at inidicies: Range<Int>) {
        tableView?.performBatchUpdates {
            let indexPaths =
                inidicies
                .map { i in
                    IndexPath(row: i, section: 0)
                }
            tableView?.insertRows(at: indexPaths, with: .automatic)
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
        guard let presenter else {
            return 0
        }

        let imageSize = presenter.photos[indexPath.row].size

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth =
            tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let scale = imageViewWidth / imageWidth
        return imageSize.height * scale + imageInsets.top + imageInsets.bottom
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        presenter?.photos.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        guard let imageListCell = cell as? ImagesListCell, let presenter else {
            print("[ImagesListViewController] can't cast custom ImagesListCell")
            return UITableViewCell()
        }

        configCell(
            for: imageListCell,
            with: indexPath,
            photo: presenter.photos[indexPath.row]
        )

        return imageListCell
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let presenter else {
            return
        }

        if indexPath.row == presenter.photos.count - 1 {
            presenter.loadMorePhotos()
        }
    }

    private func configCell(
        for cell: ImagesListCell,
        with index: IndexPath,
        photo: Photo
    ) {
        cell.delegate = self

        cell.backgroundImageView.kf.indicatorType = .activity
        cell.backgroundImageView.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(resource: .imageStub)
        )
        cell.backgroundImageView.layer.cornerRadius = 16
        cell.backgroundImageView.layer.masksToBounds = true
        cell.backgroundImageView.contentMode = .scaleAspectFit

        if let date = photo.createdAt {
            cell.dateLabel.text = DateFormatter.russianDate
                .string(from: date)
        } else {
            print("[ImagesListViewController] no date for photo: \(photo.id)")
        }

        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: Like delegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else {
            return
        }

        presenter?.imageListCellDidTapLike(at: indexPath)
    }
}
