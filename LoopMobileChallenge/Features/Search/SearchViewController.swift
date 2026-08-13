import UIKit

final class SearchViewController: UIViewController {
    private var viewModel: SearchViewModel?
    private var needsRefresh = false
    private var favoritesObserver: NSObjectProtocol?
    private var movies: [Movie] = []
    private var currentQuery = ""
    private let rowTapFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 101
        tableView.estimatedRowHeight = 101
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            MovieSummaryCell.self,
            forCellReuseIdentifier: String(describing: MovieSummaryCell.self)
        )
        return tableView
    }()

    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let searchController = UISearchController(searchResultsController: nil)

    static func instantiate(viewModel: SearchViewModel) -> SearchViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "SearchViewController"
        ) as? SearchViewController else {
            return nil
        }

        viewController.viewModel = viewModel
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "All Movies"
        setupSearchController()
        setupUI()
        bindViewModel()
        observeFavoritesChanges()
        rowTapFeedbackGenerator.prepare()
        viewModel?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rowTapFeedbackGenerator.prepare()

        guard needsRefresh else {
            return
        }

        viewModel?.refresh()
        needsRefresh = false
    }

    deinit {
        if let favoritesObserver {
            NotificationCenter.default.removeObserver(favoritesObserver)
        }
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            noResultsLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func bindViewModel() {
        viewModel?.onResultsChange = { [weak self] movies, query in
            self?.render(movies: movies, query: query)
        }
    }

    private func render(movies: [Movie], query: String) {
        self.movies = movies
        currentQuery = query

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShowNoResults = !trimmedQuery.isEmpty && movies.isEmpty

        noResultsLabel.text = "No results found for \"\(query)\""
        noResultsLabel.isHidden = !shouldShowNoResults
        tableView.isHidden = shouldShowNoResults
        tableView.reloadData()
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

    private func presentMovieDetail(_ movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel?.updateQuery(searchController.searchBar.text ?? "")
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
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

        cell.horizontalContentInset = 30
        cell.configure(with: movie, isFavorite: viewModel?.isFavorite(id: movie.id) ?? false)
        cell.onFavoriteToggle = { [weak self] movieID in
            self?.viewModel?.toggleFavorite(id: movieID)
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
