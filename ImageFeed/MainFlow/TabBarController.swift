import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
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
