import UIKit

final class HomeViewController: UIViewController {
    private var needsRefresh = false
    private var favoritesObserver: NSObjectProtocol?
    private var movies: [Movie] = []

    private let viewModel = HomeViewModel(
        movieCatalog: MovieCatalog(),
        favoritesManager: FavoritesManager(),
        profileStore: ProfileStore()
    )

    private let profileNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.numberOfLines = 1
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.label, for: .normal)
        return button
    }()

    private let headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.text = "Hello 👋"
        label.textAlignment = .right
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorInset = .zero
        return tableView
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .trailing
        return stackView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateHeader()

        guard needsRefresh else {
            return
        }

        viewModel.refreshViewState()
        movies = viewModel.allMovies()
        tableView.reloadData()
        needsRefresh = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
        observeFavoritesChanges()

        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.loadCatalog()
            self.movies = self.viewModel.allMovies()
            self.tableView.reloadData()
        }
    }

    deinit {
        if let favoritesObserver {
            NotificationCenter.default.removeObserver(favoritesObserver)
        }
    }

    private func setupUI() {
        headerStackView.addArrangedSubview(profileNameButton)
        headerStackView.addArrangedSubview(headerSubtitleLabel)

        profileNameButton.menu = makeProfileMenu()
        profileNameButton.showsMenuAsPrimaryAction = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HomeMovieSummaryCell.self, forCellReuseIdentifier: String(describing: HomeMovieSummaryCell.self))

        view.addSubview(headerStackView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        updateHeader()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .loading:
                self.movies = []
                self.tableView.reloadData()
            case .loaded:
                self.movies = self.viewModel.allMovies()
                self.tableView.reloadData()
            case .failed:
                self.movies = []
                self.tableView.reloadData()
            }
        }
    }

    private func updateHeader() {
        let displayName = viewModel.displayName
        profileNameButton.setTitle(displayName.isEmpty ? "Welcome" : displayName, for: .normal)
    }

    private func observeFavoritesChanges() {
        favoritesObserver = NotificationCenter.default.addObserver(
            forName: .favoritesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.needsRefresh = true
        }
    }

    private func makeProfileMenu() -> UIMenu {
        let deleteAction = UIAction(
            title: "Delete profile and restart app",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteProfileAndRestart()
        }

        return UIMenu(title: "", children: [deleteAction])
    }

    private func deleteProfileAndRestart() {
        viewModel.profileStore.deleteCurrentProfile()

        guard let window = view.window,
              let scene = window.windowScene,
              let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
            return
        }

        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
            window.rootViewController = initialViewController
        })

        scene.windows.first?.makeKeyAndVisible()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: HomeMovieSummaryCell.self),
            for: indexPath
        ) as? HomeMovieSummaryCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }

        cell.configure(with: movies[indexPath.row])
        return cell
    }
}
