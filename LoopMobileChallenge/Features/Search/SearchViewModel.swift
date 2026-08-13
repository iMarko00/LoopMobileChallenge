import Foundation

@MainActor
final class SearchViewModel {
    private let movieCatalog: MovieCatalog
    private let favoritesManager: FavoritesManaging
    private var currentQuery = ""

    private(set) var moviesToDisplay: [Movie] = []
    var onResultsChange: (([Movie], String) -> Void)?

    init(movieCatalog: MovieCatalog, favoritesManager: FavoritesManaging) {
        self.movieCatalog = movieCatalog
        self.favoritesManager = favoritesManager
        refresh()
    }

    func search(query: String) -> [Movie] {
        guard case .loaded = movieCatalog.state else {
            return []
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return movieCatalog.allMovieIDs.compactMap { movieCatalog.movie(for: $0) }
        }

        return movieCatalog.allMovieIDs
            .compactMap { movieCatalog.movie(for: $0) }
            .filter { movie in
                let releaseYear = String(movie.releaseDate.prefix(4))

                return movie.title.localizedStandardContains(trimmedQuery)
                    || movie.overview.localizedStandardContains(trimmedQuery)
                    || releaseYear.localizedStandardContains(trimmedQuery)
            }
    }

    func updateQuery(_ query: String) {
        currentQuery = query
        refresh()
    }

    func refresh() {
        moviesToDisplay = search(query: currentQuery)
        onResultsChange?(moviesToDisplay, currentQuery)
    }

    func toggleFavorite(id: Int) {
        favoritesManager.toggleFavorite(id: id)
        refresh()
    }

    func isFavorite(id: Int) -> Bool {
        favoritesManager.isFavorite(id: id)
    }
}
