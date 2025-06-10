import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListPresenter = ImagesListPresenter(
            imagesService: ImagesListService.shared
        )
        guard
            let imagesListViewController = storyboard.instantiateViewController(
                withIdentifier: "ImagesListViewController"
            ) as? ImagesListViewController
        else {
            return
        }
        imagesListViewController.configure(presenter: imagesListPresenter)

        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfilePresenter(
            profileImageService: ProfileImageService.shared,
            profileService: ProfileService.shared,
            logoutService: ProfileLogoutService.shared
        )
        profileViewController.configure(presenter: profileViewPresenter)

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .profileActive),
            selectedImage: nil
        )
        self.viewControllers = [
            imagesListViewController, profileViewController,
        ]
    }
}
