import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    private let imagesService = ImagesListService.shared

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

        imagesService.fetchPhotosNextPage()
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination
                    as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let fullImageUrl = URL(
                    string: photos[indexPath.row].largeImageURL
                )
            else {
                return
            }
            viewController.imageUrl = fullImageUrl
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
        let imageSize = photos[indexPath.row].size

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
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        guard let imageListCell = cell as? ImagesListCell else {
            print("[ImagesListViewController] can't cast custom ImagesListCell")
            return UITableViewCell()
        }

        configCell(
            for: imageListCell,
            with: indexPath,
            photo: photos[indexPath.row]
        )

        return imageListCell
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            imagesService.fetchPhotosNextPage()
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

    private func updateTableViewAnimated() {
        let updatedPhotos = imagesService.photos
        let oldPhotosCount = photos.count

        photos = updatedPhotos

        if updatedPhotos.count > oldPhotosCount {
            tableView.performBatchUpdates {
                let indexPaths =
                    (oldPhotosCount..<updatedPhotos.count)
                    .map { i in
                        IndexPath(row: i, section: 0)
                    }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}

// MARK: Like delegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let photo = photos[indexPath.row]
        let isLiked = !photo.isLiked
        UIBlockingProgressHUD.show()
        imagesService.changeLike(photoId: photo.id, isLike: isLiked) {
            [weak self] result in
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success:
                self?.photos[indexPath.row].isLiked.toggle()
                cell.setIsLiked(isLiked)
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось поставить лайк: \(error)",
                    preferredStyle: .alert
                )
                alert
                    .addAction(
                        UIAlertAction(
                            title: "Oк",
                            style: .default,
                            handler: { _ in
                                alert.dismiss(animated: true)
                            }
                        )
                    )

                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
