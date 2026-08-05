import Foundation

final class SignupViewModel {
    private let profileStore: ProfileStoring

    init(profileStore: ProfileStoring) {
        self.profileStore = profileStore
    }

    func canSubmit(name: String, email: String, password: String, repeatPassword: String) -> Bool {
        isNameValid(name)
            && isEmailValid(email)
            && doPasswordsMatch(password: password, repeatPassword: repeatPassword)
    }

    func isNameValid(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func isEmailValid(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@") else {
            return false
        }

        let components = trimmedEmail.split(separator: "@")
        guard components.count == 2,
              !components[0].isEmpty,
              components[1].contains(".") else {
            return false
        }

        return true
    }

    func doPasswordsMatch(password: String, repeatPassword: String) -> Bool {
        !password.isEmpty && !repeatPassword.isEmpty && password == repeatPassword
    }

    func submit(name: String, email: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isNameValid(trimmedName), isEmailValid(trimmedEmail) else {
            return
        }

        let profile = Profile(name: trimmedName, email: trimmedEmail)
        profileStore.save(profile)
    }
}
