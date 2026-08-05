import Foundation

protocol ProfileStoring {
    func save(_ profile: Profile)
    func deleteCurrentProfile()
    var currentProfile: Profile? { get }
}
