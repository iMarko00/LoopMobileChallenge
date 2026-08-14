import Foundation

@MainActor
final public class HomeViewModel {
    enum ViewState {
        case loading
        case loaded(movies: [Movie], favorites: [Movie])
        case failed(Error)
    }

    private let movieCatalog: MovieCatalog
    private let favoritesManager: FavoritesManaging
    let profileStore: ProfileStore

    private(set) var viewState: ViewState = .loading
    var onStateChange: ((ViewState) -> Void)?

    init(movieCatalog: MovieCatalog, favoritesManager: FavoritesManaging, profileStore: ProfileStore) {
        self.movieCatalog = movieCatalog
        self.favoritesManager = favoritesManager
        self.profileStore = profileStore
    }

    func loadCatalog() async {
        setViewState(.loading)
        await movieCatalog.load()
        refreshViewState()
    }

    func refreshViewState() {
        switch movieCatalog.state {
        case .idle, .loading:
            setViewState(.loading)
        case .failed(let error):
            setViewState(.failed(error))
        case .loaded:
            guard !movieCatalog.allMovieIDs.isEmpty else {
                let error = NSError(
                    domain: "HomeViewModel",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Movie catalog is empty"]
                )
                setViewState(.failed(error))
                return
            }

            let movies = movieCatalog.staffPickIDs.compactMap { movieCatalog.movie(for: $0) }
            let favorites = movieCatalog.allMovieIDs
                .filter { favoritesManager.isFavorite(id: $0) }
                .compactMap { movieCatalog.movie(for: $0) }

            setViewState(.loaded(movies: movies, favorites: favorites))
        }
    }

    func toggleFavorite(id: Int) {
        favoritesManager.toggleFavorite(id: id)
        refreshViewState()
    }

    func isFavorite(id: Int) -> Bool {
        favoritesManager.isFavorite(id: id)
    }

    func allMovies() -> [Movie] {
        guard case .loaded = movieCatalog.state else {
            return []
        }

        return movieCatalog.allMovieIDs.compactMap { movieCatalog.movie(for: $0) }
    }

    private func setViewState(_ newState: ViewState) {
        viewState = newState
        onStateChange?(newState)
    }
    
    var canOpenSearch: Bool {
        if case .loaded = movieCatalog.state {
            return true
        }
        
        return false
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(movieCatalog: movieCatalog, favoritesManager: favoritesManager)
    }
    
    var displayName: String {
        profileStore.currentProfile?.name ?? ""
    }
}
