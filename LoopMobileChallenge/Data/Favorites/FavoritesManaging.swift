import Foundation

protocol FavoritesManaging {
    func isFavorite(id: Int) -> Bool
    func toggleFavorite(id: Int)
    var favoriteIDs: Set<Int> { get }
}
