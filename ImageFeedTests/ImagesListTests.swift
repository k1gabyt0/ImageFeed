import XCTest

@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ImagesListViewController()
        let spyPresenter = ImagesListPresenterSpy()
        viewController.configure(presenter: spyPresenter)

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(spyPresenter.viewDidLoadCalled)
    }

    func testPresenterLoadPhotos() {
        // given
        let viewControllerSpy = ImagesListViewSpy()
        let presenter = ImagesListPresenter(
            imagesService: ImagesServiceMock(isSuccessChangingLike: true)
        )
        presenter.view = viewControllerSpy

        presenter.viewDidLoad()
        let imagesLoadedExpectation = expectation(
            forNotification: ImagesListService.didChangeNotification,
            object: nil
        )
        
        // when
        presenter.loadMorePhotos()
        wait(for: [imagesLoadedExpectation], timeout: 4)

        // then
        XCTAssertTrue(viewControllerSpy.insertRowsCalled)
    }

    func testPresenterSuccefullLike() {
        // given
        let viewControllerSpy = ImagesListViewSpy()
        let presenter = ImagesListPresenter(
            imagesService: ImagesServiceMock()
        )
        presenter.view = viewControllerSpy

        presenter.viewDidLoad()
        let imagesLoadedExpectation = expectation(
            forNotification: ImagesListService.didChangeNotification,
            object: nil
        )
        presenter.loadMorePhotos()
        wait(for: [imagesLoadedExpectation], timeout: 4)
        
        // when
        presenter.imageListCellDidTapLike(at: IndexPath(row: 0, section: 0))

        // then
        XCTAssertTrue(viewControllerSpy.setCellLikeCalled)
    }
    
    func testPresenterFailedLikeAndShowAlert() {
        // given
        let viewControllerSpy = ImagesListViewSpy()
        let presenter = ImagesListPresenter(
            imagesService: ImagesServiceMock(isSuccessChangingLike: false)
        )
        presenter.view = viewControllerSpy

        presenter.viewDidLoad()
        let imagesLoadedExpectation = expectation(
            forNotification: ImagesListService.didChangeNotification,
            object: nil
        )
        presenter.loadMorePhotos()
        wait(for: [imagesLoadedExpectation], timeout: 4)
        
        // when
        presenter.imageListCellDidTapLike(at: IndexPath(row: 0, section: 0))

        // then
        XCTAssertFalse(viewControllerSpy.setCellLikeCalled)
        XCTAssertTrue(viewControllerSpy.showAlertCalled)
    }
}
