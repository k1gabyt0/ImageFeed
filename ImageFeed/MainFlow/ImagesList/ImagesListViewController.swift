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
                let cell = tableView.cellForRow(at: indexPath),
                let image = (cell as? ImagesListCell)?.backgroundImageView.image
            else {
                return
            }
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

        let imageUrl = photos[indexPath.row].thumbImageURL
        configCell(for: imageListCell, with: indexPath, imageUrl: imageUrl)

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
        imageUrl: String
    ) {
        cell.backgroundImageView.kf.indicatorType = .activity
        cell.backgroundImageView.kf.setImage(
            with: URL(string: imageUrl),
            placeholder: UIImage(resource: .imageStub)
        )
        cell.backgroundImageView.layer.cornerRadius = 16
        cell.backgroundImageView.layer.masksToBounds = true
        cell.backgroundImageView.contentMode = .scaleAspectFit

        cell.dateLabel.text = DateFormatter.russianDate.string(from: Date())

        let likeImage = UIImage(
            resource: index.row % 2 == 0
                ? .likeActive
                : .likeInactive
        )
        cell.likeButton.setImage(likeImage, for: .normal)
    }

    private func updateTableViewAnimated() {
        let oldPhotosCount = photos.count
        let newlyLoadedPhotos = imagesService.photos
        photos += newlyLoadedPhotos

        tableView.performBatchUpdates {
            let indexPaths =
                (oldPhotosCount..<oldPhotosCount + newlyLoadedPhotos.count)
                .map { i in
                    IndexPath(row: i, section: 0)
                }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}
