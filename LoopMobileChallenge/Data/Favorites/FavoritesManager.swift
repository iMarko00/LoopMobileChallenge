import Foundation

final class FavoritesManager: FavoritesManaging {
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let favoritesKey: String

    init(
        userDefaults: UserDefaults = .standard,
        notificationCenter: NotificationCenter = .default,
        favoritesKey: String = "favorites.ids"
    ) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.favoritesKey = favoritesKey
    }

    var favoriteIDs: Set<Int> {
        let storedIDs = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
        return Set(storedIDs)
    }

    func isFavorite(id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(id: Int) {
        var ids = favoriteIDs

        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }

        userDefaults.set(Array(ids), forKey: favoritesKey)
        notificationCenter.post(name: .favoritesDidChange, object: nil)
    }
}
