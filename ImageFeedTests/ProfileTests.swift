import XCTest

@testable import ImageFeed

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let spyPresenter = ProfilePresenterSpy()
        viewController.configure(presenter: spyPresenter)

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(spyPresenter.viewDidLoadCalled)
    }

    func testViewControllerShouldUpdateAvatarOnEvent() {
        // given
        let spyController = ViewControllerSpy()
        let presenter = ProfilePresenter(
            profileImageService: ProfileImageServiceMock(),
            profileService: ProfileServiceStub(),
            logoutService: LogoutServiceStub()
        )
        presenter.view = spyController

        // when
        presenter.viewDidLoad()
        let imageLoadedExpectation = expectation(
            forNotification: ProfileImageService.didChangeNotification,
            object: nil
        )
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: nil
        )

        // then
        wait(for: [imageLoadedExpectation], timeout: 4)
        XCTAssertTrue(spyController.setAvatarImageCalled)
    }
    
    func testViewControllerShouldShowAlertOnLogout() {
        // given
        let spyController = ViewControllerSpy()
        let presenter = ProfilePresenter(
            profileImageService: ProfileImageServiceMock(),
            profileService: ProfileServiceStub(),
            logoutService: LogoutServiceStub()
        )
        presenter.view = spyController

        // when
        presenter.logoutButtonTouched()

        // then
        XCTAssertTrue(spyController.showAlertCalled)
    }
}
