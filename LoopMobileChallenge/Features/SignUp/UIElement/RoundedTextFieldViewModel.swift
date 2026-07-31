import Foundation

final class RoundedTextFieldViewModel {
    var promptText: String {
        didSet {
            if showsPromptText {
                displayedText = promptText
            }
        }
    }

    let isSecuredTextField: Bool
    let isEmailField: Bool
    let isPasswordField: Bool

    private(set) var showsPromptText = true
    private(set) var isTextHidden = true
    private(set) var isValidEmail = true
    private(set) var rawText = ""
    private(set) var displayedText = ""

    init(
        promptText: String,
        isSecuredTextField: Bool,
        isEmailField: Bool,
        isPasswordField: Bool
    ) {
        self.promptText = promptText
        self.isSecuredTextField = isSecuredTextField
        self.isEmailField = isEmailField
        self.isPasswordField = isPasswordField
        applyPromptState()
    }

    func beginEditing() {
        if showsPromptText {
            showsPromptText = false
            displayedText = ""
        }
        updateDisplayedFromRaw()
        validateEmailIfNeeded()
    }

    func endEditing() {
        let normalized = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty {
            applyPromptState()
        }
    }

    func toggleVisibility() {
        guard isSecuredTextField else { return }
        isTextHidden.toggle()
        updateDisplayedFromRaw()
    }

    func updateFromEditing(displayedValue: String) {
        guard !showsPromptText else { return }

        if isSecuredTextField {
            if isTextHidden {
                let previousMasked = String(repeating: "*", count: rawText.count)
                if displayedValue.count > previousMasked.count {
                    let appended = String(displayedValue.dropFirst(previousMasked.count))
                    rawText += appended
                } else if displayedValue.count < previousMasked.count {
                    rawText = String(rawText.prefix(displayedValue.count))
                }
            } else {
                rawText = displayedValue
            }
        } else {
            rawText = displayedValue
        }

        updateDisplayedFromRaw()
        validateEmailIfNeeded()
    }

    @discardableResult
    func validateEmailIfNeeded() -> Bool {
        guard isEmailField else {
            return true
        }

        let normalized = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        isValidEmail = Self.isValidEmailFormat(normalized)
        return isValidEmail
    }

    private func applyPromptState() {
        showsPromptText = true
        rawText = ""
        displayedText = promptText
        validateEmailIfNeeded()
    }

    private func updateDisplayedFromRaw() {
        guard !showsPromptText else {
            displayedText = promptText
            return
        }

        if isSecuredTextField, isTextHidden {
            displayedText = String(repeating: "*", count: rawText.count)
        } else {
            displayedText = rawText
        }
    }

    private static func isValidEmailFormat(_ value: String) -> Bool {
        if value.isEmpty {
            return false
        }

        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}
