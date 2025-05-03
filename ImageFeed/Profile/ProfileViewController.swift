import UIKit

final class ProfileViewController: UIViewController {
    private var profileImageView: UIImageView!
    private var nameLabel: UILabel!
    private var nicknameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!
    
    private var profileData = ProfileService.shared.profile

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .ypBlack

        profileImageView = UIImageView(
            image: UIImage(resource: .avatar)
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
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
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
}
