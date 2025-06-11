import UIKit

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var photos: [Photo] { get }

    func viewDidLoad()
    func imageListCellDidTapLike(at index: IndexPath)
    func loadMorePhotos()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?

    private(set) var photos: [Photo] = []

    private var imagesService: ImagesListServiceProtocol
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    init(imagesService: ImagesListServiceProtocol) {
        self.imagesService = imagesService
    }

    func viewDidLoad() {
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTable()
            }
    }

    func imageListCellDidTapLike(at index: IndexPath) {
        let photo = photos[index.row]
        let isLiked = !photo.isLiked

        UIBlockingProgressHUD.show()
        imagesService.changeLike(photoId: photo.id, isLike: isLiked) {
            [weak self] result in
            defer {
                UIBlockingProgressHUD.dismiss()
            }
            
            guard let self else {
                return
            }
            
            switch result {
            case .success:
                self.photos[index.row].isLiked.toggle()
                self.view?.setCellLike(isLiked: isLiked, at: index)
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

                self.view?.showAlert(alert)
            }
        }
    }
    
    func loadMorePhotos() {
        imagesService.fetchPhotosNextPage()
    }
    
    private func updateTable() {
        let updatedPhotos = imagesService.photos
        let oldPhotosCount = photos.count

        photos = updatedPhotos

        if updatedPhotos.count > oldPhotosCount {
            view?.insertRows(at: oldPhotosCount..<updatedPhotos.count)
        }
    }
}
