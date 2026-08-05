import UIKit

final class SplashViewController: UIViewController {
    private let profileStore = ProfileStore()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fetching the newest movies..."
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = UIFont(name: "SFProText-Semibold", size: 18) ?? .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spinner.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.showSignUp()
        }
    }

    private func setupUI() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -14),

            subtitleLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 18),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func showSignUp() {
        guard presentedViewController == nil else { return }

        if profileStore.currentProfile != nil {
            let homeViewController = HomeViewController()
            homeViewController.modalPresentationStyle = .fullScreen
            homeViewController.modalTransitionStyle = .crossDissolve
            present(homeViewController, animated: true)
            return
        }

        let signUpViewController = SignUpViewController()
        signUpViewController.modalPresentationStyle = .fullScreen
        signUpViewController.modalTransitionStyle = .crossDissolve
        present(signUpViewController, animated: true)
    }
}