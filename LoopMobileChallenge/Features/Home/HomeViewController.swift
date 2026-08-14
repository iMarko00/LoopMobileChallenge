import UIKit

final class HomeViewController: UIViewController {
    private var needsRefresh = false
    private var favoritesObserver: NSObjectProtocol?
    private var movies: [Movie] = []
    private var favoriteMovies: [Movie] = []
    private var staffPicksTableHeightConstraint: NSLayoutConstraint?
    private let scrollSoftEdgeEffect = ScrollSoftEdgeEffect(height: 20)
    private let rowTapFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let moreButtonFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    private let viewModel = HomeViewModel(
        movieCatalog: MovieCatalog(),
        favoritesManager: FavoritesManager(),
        profileStore: ProfileStore()
    )

    private let profileNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Bold", size: 33) ?? .systemFont(ofSize: 33, weight: .bold)
        
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.numberOfLines = 1
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.label, for: .normal)
        return button
    }()

    private let headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFProText-Medium", size: 11) ?? .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Hello 👋"
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: "magnifyingglass")
        config.contentInsets = .zero
        config.cornerStyle = .capsule
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.isEnabled = false
        button.accessibilityLabel = "Search"
        return button
    }()

    private let yourFavoritesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let regularFont = UIFont(name: "SFProText-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
        let heavyFont = UIFont(name: "SFProText-Heavy", size: 12) ?? .systemFont(ofSize: 12, weight: .heavy)
        let attributedText = NSMutableAttributedString(
            string: "YOUR ",
            attributes: [.font: regularFont]
        )
        attributedText.append(
            NSAttributedString(
                string: "FAVORITES",
                attributes: [.font: heavyFont]
            )
        )

        label.attributedText = attributedText
        label.textColor = UIColor(red: 20.0 / 255.0, green: 28.0 / 255.0, blue: 37.0 / 255.0, alpha: 1)
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let staffPicksTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let regularFont = UIFont(name: "SFProText-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
        let boldFont = UIFont(name: "SFProText-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)
        let attributedText = NSMutableAttributedString(
            string: "OUR ",
            attributes: [.font: regularFont]
        )
        attributedText.append(
            NSAttributedString(
                string: "STAFF PICKS",
                attributes: [.font: boldFont]
            )
        )

        label.attributedText = attributedText
        label.textColor = UIColor(red: 20.0 / 255.0, green: 28.0 / 255.0, blue: 37.0 / 255.0, alpha: 1)
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let favoritesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.layer.masksToBounds = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 16)
        return collectionView
    }()

    private let staffPicksTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 101
        tableView.estimatedRowHeight = 101
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()

    private let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    private let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stateOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()

    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private let failedStateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.isHidden = true
        return stackView
    }()

    private let failedStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Something went wrong"
        label.font = UIFont(name: "SFProText-Semibold", size: 20) ?? .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Try again", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
        return button
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }()

    private let favoritesEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "You have no favorites selected yet"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont(name: "SFProText-Regular", size: 15) ?? .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateHeader()
        rowTapFeedbackGenerator.prepare()
        moreButtonFeedbackGenerator.prepare()

        guard needsRefresh else {
            return
        }

        viewModel.refreshViewState()
        needsRefresh = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
        observeFavoritesChanges()
        rowTapFeedbackGenerator.prepare()
        moreButtonFeedbackGenerator.prepare()

        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.loadCatalog()
        }
    }

    deinit {
        if let favoritesObserver {
            NotificationCenter.default.removeObserver(favoritesObserver)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateStaffPicksTableHeight()
        scrollSoftEdgeEffect.updateFrames()
    }

    private func setupUI() {
        headerStackView.addArrangedSubview(profileNameButton)
        headerStackView.addArrangedSubview(headerSubtitleLabel)

        profileNameButton.menu = makeProfileMenu()
        profileNameButton.showsMenuAsPrimaryAction = false
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)

        staffPicksTableView.dataSource = self
        staffPicksTableView.delegate = self
        staffPicksTableView.register(MovieSummaryCell.self, forCellReuseIdentifier: String(describing: MovieSummaryCell.self))

        favoritesCollectionView.dataSource = self
        favoritesCollectionView.delegate = self
        favoritesCollectionView.allowsSelection = true
        favoritesCollectionView.register(
            HomeFavoriteMovieCell.self,
            forCellWithReuseIdentifier: String(describing: HomeFavoriteMovieCell.self)
        )
        favoritesCollectionView.register(
            HomeFavoriteMoviesMoreCell.self,
            forCellWithReuseIdentifier: String(describing: HomeFavoriteMoviesMoreCell.self)
        )

        view.addSubview(contentScrollView)
        view.addSubview(stateOverlayView)

        stateOverlayView.addSubview(loadingSpinner)
        stateOverlayView.addSubview(failedStateStackView)
        failedStateStackView.addArrangedSubview(failedStateLabel)
        failedStateStackView.addArrangedSubview(retryButton)

        contentScrollView.addSubview(contentContainerView)

        contentContainerView.addSubview(headerStackView)
        contentContainerView.addSubview(yourFavoritesLabel)
        contentContainerView.addSubview(favoritesCollectionView)
        contentContainerView.addSubview(staffPicksTitleLabel)
        contentContainerView.addSubview(staffPicksTableView)

        let tableHeightConstraint = staffPicksTableView.heightAnchor.constraint(equalToConstant: 0)
        staffPicksTableHeightConstraint = tableHeightConstraint

        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stateOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            stateOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingSpinner.centerXAnchor.constraint(equalTo: stateOverlayView.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: stateOverlayView.centerYAnchor),

            failedStateStackView.centerXAnchor.constraint(equalTo: stateOverlayView.centerXAnchor),
            failedStateStackView.centerYAnchor.constraint(equalTo: stateOverlayView.centerYAnchor),
            failedStateStackView.leadingAnchor.constraint(greaterThanOrEqualTo: stateOverlayView.leadingAnchor, constant: 24),
            failedStateStackView.trailingAnchor.constraint(lessThanOrEqualTo: stateOverlayView.trailingAnchor, constant: -24),

            contentContainerView.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor),
            contentContainerView.widthAnchor.constraint(equalTo: contentScrollView.frameLayoutGuide.widthAnchor),

            headerStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 0),
            headerStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),

            yourFavoritesLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 20),
            yourFavoritesLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 26),

            favoritesCollectionView.topAnchor.constraint(equalTo: yourFavoritesLabel.bottomAnchor, constant: 12),
            favoritesCollectionView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            favoritesCollectionView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            favoritesCollectionView.heightAnchor.constraint(equalToConstant: 286),

            staffPicksTitleLabel.topAnchor.constraint(equalTo: favoritesCollectionView.bottomAnchor, constant: 40),
            staffPicksTitleLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 20),

            staffPicksTableView.topAnchor.constraint(equalTo: staffPicksTitleLabel.bottomAnchor, constant: 20),
            staffPicksTableView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 20),
            staffPicksTableView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -20),
            staffPicksTableView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            tableHeightConstraint
        ])

        NSLayoutConstraint.activate([
            searchButton.widthAnchor.constraint(equalToConstant: 44),
            searchButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        scrollSoftEdgeEffect.install(on: contentScrollView, in: view)
        updateHeader()
    }
    
    @objc private func didTapSearch() {
        guard viewModel.canOpenSearch,
              let navigationController,
              let searchViewController = SearchViewController.instantiate(
                viewModel: viewModel.makeSearchViewModel()
              ) else {
            return
        }
        
        navigationController.pushViewController(searchViewController, animated: true)
    }

    @objc private func didTapRetry() {
        setScreenState(.loading)

        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.loadCatalog()
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            self.render(state: state)
        }
    }

    private func render(state: HomeViewModel.ViewState) {
        switch state {
        case .loading:
            movies = []
            favoriteMovies = []
            searchButton.isEnabled = false
            setScreenState(.loading)
        case .loaded(let allMovies, let favorites):
            movies = allMovies
            favoriteMovies = favorites
            searchButton.isEnabled = true
            setScreenState(.content)
        case .failed:
            movies = []
            favoriteMovies = []
            searchButton.isEnabled = false
            setScreenState(.failed)
        }

        updateFavoritesEmptyState()

        staffPicksTableView.reloadData()
        favoritesCollectionView.reloadData()
        updateStaffPicksTableHeight()

        // Recalculate after the run loop to capture final auto-layout cell heights
        DispatchQueue.main.async { [weak self] in
            self?.updateStaffPicksTableHeight()
        }
    }

    private enum ScreenState {
        case content
        case loading
        case failed
    }

    private func setScreenState(_ state: ScreenState) {
        switch state {
        case .content:
            stateOverlayView.isHidden = true
            failedStateStackView.isHidden = true
            loadingSpinner.stopAnimating()
        case .loading:
            stateOverlayView.isHidden = false
            failedStateStackView.isHidden = true
            loadingSpinner.startAnimating()
        case .failed:
            stateOverlayView.isHidden = false
            loadingSpinner.stopAnimating()
            failedStateStackView.isHidden = false
        }
    }

    private func updateFavoritesEmptyState() {
        favoritesCollectionView.backgroundView = favoriteMovies.isEmpty ? favoritesEmptyLabel : nil
    }

    private func updateStaffPicksTableHeight() {
        staffPicksTableView.layoutIfNeeded()
        staffPicksTableView.beginUpdates()
        staffPicksTableView.endUpdates()

        let contentHeight = staffPicksTableView.contentSize.height
        guard staffPicksTableHeightConstraint?.constant != contentHeight else {
            return
        }

        staffPicksTableHeightConstraint?.constant = contentHeight
    }

    private func updateHeader() {
        let displayName = viewModel.displayName
        profileNameButton.setTitle(displayName, for: .normal)
    }

    private func observeFavoritesChanges() {
        favoritesObserver = NotificationCenter.default.addObserver(
            forName: .favoritesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleFavoritesDidChange()
        }
    }

    private func handleFavoritesDidChange() {
        needsRefresh = true

        // If no modal is covering Home, update immediately so favorites stay in sync
        guard presentedViewController == nil else {
            return
        }

        viewModel.refreshViewState()
        needsRefresh = false
    }

    private func showMoreFeatureNotImplementedAlert() {
        let alertController = UIAlertController(
            title: nil,
            message: "this feature wasnt implemented on purpose",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    private func presentMovieDetail(_ movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        detailVC.onClose = { [weak self] in
            self?.viewModel.refreshViewState()
            self?.needsRefresh = false
        }
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
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
        let movie = movies[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: MovieSummaryCell.self),
            for: indexPath
        ) as? MovieSummaryCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }

        cell.configure(with: movie, isFavorite: viewModel.isFavorite(id: movie.id))
        cell.onFavoriteToggle = { [weak self] movieID in
            self?.viewModel.toggleFavorite(id: movieID)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        rowTapFeedbackGenerator.impactOccurred()
        rowTapFeedbackGenerator.prepare()

        let movie = movies[indexPath.row]

        if let cell = tableView.cellForRow(at: indexPath) {
            TapInteractionFeedback.darkenFlash(on: cell.contentView) { [weak self] in
                self?.presentMovieDetail(movie)
            }
            return
        }

        presentMovieDetail(movie)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(favoriteMovies.count, 3) + (favoriteMovies.count >= 3 ? 1 : 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 3 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: HomeFavoriteMoviesMoreCell.self),
                for: indexPath
            ) as? HomeFavoriteMoviesMoreCell else {
                return UICollectionViewCell()
            }
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: HomeFavoriteMovieCell.self),
            for: indexPath
        ) as? HomeFavoriteMovieCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: favoriteMovies[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 3 {
            return CGSize(width: 91, height: 33)
        }
        
        return CGSize(width: 182, height: 270)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard indexPath.item < min(favoriteMovies.count, 3) else {
            moreButtonFeedbackGenerator.impactOccurred()
            moreButtonFeedbackGenerator.prepare()

            if let moreCell = collectionView.cellForItem(at: indexPath) {
                TapInteractionFeedback.pulseExpand(on: moreCell.contentView) { [weak self] in
                    self?.showMoreFeatureNotImplementedAlert()
                }
                return
            }

            showMoreFeatureNotImplementedAlert()
            return
        }

        let movie = favoriteMovies[indexPath.item]
        moreButtonFeedbackGenerator.impactOccurred()
        moreButtonFeedbackGenerator.prepare()

        if let cell = collectionView.cellForItem(at: indexPath) {
            TapInteractionFeedback.pulseExpand(on: cell.contentView) { [weak self] in
                self?.presentMovieDetail(movie)
            }
            return
        }

        presentMovieDetail(movie)
    }
}
