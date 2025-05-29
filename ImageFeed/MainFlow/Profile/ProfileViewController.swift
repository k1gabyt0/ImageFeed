import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {
    private var profileImageView: UIImageView?
    private var nameLabel: UILabel?
    private var nicknameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var logoutButton: UIButton?

    private var profileData = ProfileService.shared.profile
    private var profileImageServiceObserver: NSObjectProtocol?

    private let logoutService = ProfileLogoutService.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL),
            let profileImageView
        else { return }

        profileImageView.kf.indicatorType = .activity
        profileImageView.kf
            .setImage(
                with: changeImageSize(in: url, width: 70, height: 70),
                placeholder: UIImage(resource: .stub)
            )
    }

    private func changeImageSize(in url: URL, width: Int, height: Int) -> URL {
        guard
            var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: true
            )
        else {
            return url
        }

        components.queryItems = [
            URLQueryItem(name: "w", value: String(width)),
            URLQueryItem(name: "h", value: String(height)),
        ]
        guard let updatedUrl = components.url else {
            return url
        }

        return updatedUrl
    }

    private func setupUI() {
        view.backgroundColor = .ypBlack

        profileImageView = UIImageView(
            image: UIImage(resource: .stub)
        )
        nameLabel = UILabel()
        nicknameLabel = UILabel()
        descriptionLabel = UILabel()
        logoutButton = UIButton(type: .custom)

        let profileImageViewConstraints = setupProfileImage()
        let nameLabelConstraints = setupNameLabel()
        let nicknameLabelConstraints = setupNicknameLabel()
        let descriptionLabelConstraints = setupDescriptionLabel()
        let setupLogoutButtonConstraints = setupLogoutButton()

        NSLayoutConstraint.activate(
            profileImageViewConstraints
                + nameLabelConstraints
                + nicknameLabelConstraints
                + descriptionLabelConstraints
                + setupLogoutButtonConstraints
        )
    }

    private func setupProfileImage() -> [NSLayoutConstraint] {
        guard let profileImageView else {
            return []
        }

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.setRounded()
        view.addSubview(profileImageView)

        let safeArea = view.safeAreaLayoutGuide
        return [
            profileImageView.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 32
            ),
            profileImageView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(
                equalTo: profileImageView.widthAnchor,
                multiplier: 1
            ),
        ]
    }

    private func setupNameLabel() -> [NSLayoutConstraint] {
        guard let nameLabel, let profileImageView else {
            return []
        }

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        nameLabel.text = profileData?.name
        view.addSubview(nameLabel)

        let safeArea = view.safeAreaLayoutGuide
        return [
            nameLabel.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: 8
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            nameLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: safeArea.trailingAnchor
            ),
        ]
    }

    private func setupNicknameLabel() -> [NSLayoutConstraint] {
        guard let nicknameLabel, let nameLabel else {
            return []
        }

        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        nicknameLabel.textColor = .ypGray
        nicknameLabel.text = profileData?.loginName
        view.addSubview(nicknameLabel)

        let safeArea = view.safeAreaLayoutGuide
        return [
            nicknameLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 8
            ),
            nicknameLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            nicknameLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: safeArea.trailingAnchor
            ),
        ]
    }

    private func setupDescriptionLabel() -> [NSLayoutConstraint] {
        guard let descriptionLabel, let nicknameLabel else {
            return []
        }

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.text = profileData?.bio
        view.addSubview(descriptionLabel)

        let safeArea = view.safeAreaLayoutGuide
        return [
            descriptionLabel.topAnchor.constraint(
                equalTo: nicknameLabel.bottomAnchor,
                constant: 8
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            descriptionLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: safeArea.trailingAnchor
            ),
        ]
    }

    private func setupLogoutButton() -> [NSLayoutConstraint] {
        guard let logoutButton, let profileImageView else {
            return []
        }

        logoutButton
            .addTarget(
                self,
                action: #selector(logoutButtonTouched),
                for: .touchUpInside
            )

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(
            UIImage(resource: .exit),
            for: .normal
        )
        view.addSubview(logoutButton)

        let safeArea = view.safeAreaLayoutGuide
        return [
            logoutButton.centerYAnchor.constraint(
                equalTo: profileImageView.centerYAnchor
            ),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(
                equalTo: logoutButton.heightAnchor,
                multiplier: 1
            ),
            safeArea.trailingAnchor.constraint(
                equalTo: logoutButton.trailingAnchor,
                constant: 16
            ),
        ]
    }

    @objc private func logoutButtonTouched() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        alert.addAction(
            UIAlertAction(title: "Да", style: .cancel) { [weak self] _ in
                self?.logoutService.logout()
                self?.switchToSplash()
            }
        )

        present(alert, animated: true)
    }

    private func switchToSplash() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
}
