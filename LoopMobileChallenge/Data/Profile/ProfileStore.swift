import Foundation

final class ProfileStore: ProfileStoring {
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let profileKey: String

    init(
        userDefaults: UserDefaults = .standard,
        notificationCenter: NotificationCenter = .default,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        profileKey: String = "profile.current"
    ) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.encoder = encoder
        self.decoder = decoder
        self.profileKey = profileKey
    }

    var currentProfile: Profile? {
        guard let data = userDefaults.data(forKey: profileKey) else {
            return nil
        }

        return try? decoder.decode(Profile.self, from: data)
    }

    func save(_ profile: Profile) {
        guard let data = try? encoder.encode(profile) else {
            return
        }

        userDefaults.set(data, forKey: profileKey)
        notificationCenter.post(name: .profileDidChange, object: profile)
    }

    func deleteCurrentProfile() {
        userDefaults.removeObject(forKey: profileKey)
        notificationCenter.post(name: .profileDidChange, object: nil)
    }
}
