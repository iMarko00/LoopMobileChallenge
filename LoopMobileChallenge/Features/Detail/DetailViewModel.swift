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
        movie.rating.rounded()
    }
    
    var movieBudget: String {
        movie.budget.formatted()
    }
    
    var movieOverview: String {
        movie.overview
    }
    
    var movieRevenue: String {
        movie.revenue.formatted()
    }
    
    var movieOrgLanguage: String {
        movie.language.turnLngAbbrIntoFullText()
    }
    
    var movieReleaseDate: String {
        String(movie.releaseDate.prefix(4))
    }

    var isFavorite: Bool {
        favoritesManager.isFavorite(id: movie.id)
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(id: movie.id)
    }
}

extension String {
    func turnLngAbbrIntoFullText() -> String {
        switch self {
        case "en":
            return "English"
        case "ko":
            return "Korean"
        case "fr":
            return "French"
        case "ja":
            return "Japanese"
        default:
            return self.uppercased()
        }
    }
}
