import Foundation

final class DetailViewModel {
    private let movie: Movie
    private let favoritesManager: FavoritesManaging

    init(movie: Movie, favoritesManager: FavoritesManaging) {
        self.movie = movie
        self.favoritesManager = favoritesManager
    }
    
    var moviePoserUrl: String {
        movie.posterUrl
    }
    
    var movieRating: Double {
        movie.rating
    }

    var isFavorite: Bool {
        favoritesManager.isFavorite(id: movie.id)
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(id: movie.id)
    }
}
