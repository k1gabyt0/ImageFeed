import Kingfisher
import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    func setAvatarImage(from url: URL)
    func showAlert(_ alert: UIAlertController)

    func setNameLabel(_ text: String?)
    func setNicknameLabel(_ text: String?)
    func setDescriptionLabel(_ text: String?)
}

final class ProfileViewController: UIViewController
        & ProfileViewControllerProtocol
{
    private var profileImageView: UIImageView?
    private var nameLabel: UILabel?
    private var nicknameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var logoutButton: UIButton?

    private var presenter: ProfilePresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter?.viewDidLoad()
    }

    func configure(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }

    func setAvatarImage(from url: URL) {
        guard let profileImageView else {
            return
        }

        profileImageView.kf.indicatorType = .activity
        profileImageView.kf
            .setImage(
                with: url,
                placeholder: UIImage(resource: .stub)
            )
    }

    func setNameLabel(_ text: String?) {
        nameLabel?.text = text
    }

    func setNicknameLabel(_ text: String?) {
        nicknameLabel?.text = text
    }

    func setDescriptionLabel(_ text: String?) {
        descriptionLabel?.text = text
    }
    
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
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
        presenter?.logoutButtonTouched()
    }
}
