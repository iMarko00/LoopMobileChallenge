//
//  SignUpViewController.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 29.07.26.
//

import UIKit

class SignUpViewController: UIViewController {
    private let fieldTextInset: CGFloat = 24
    private var hasAttemptedSubmit = false
    private let viewModel = SignupViewModel(profileStore: ProfileStore())

    private let emailValidationLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter valid email address"
        label.textColor = .systemRed
        label.font = UIFont(name: "SFProText-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
        label.isHidden = true
        return label
    }()

    private let passwordMismatchLabel: UILabel = {
        let label = UILabel()
        label.text = "Passwords dont match"
        label.textColor = .systemRed
        label.font = UIFont(name: "SFProText-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
        label.isHidden = true
        return label
    }()

    private var emailField: RoundedTextField?
    private var nameField: RoundedTextField?
    private var passwordField: RoundedTextField?
    private var repeatPasswordField: RoundedTextField?
    private let signUpButton = UIButton(type: .roundedRect)
    private let signUpSpinner = UIActivityIndicatorView(style: .medium)
    private var pendingSignUpWorkItem: DispatchWorkItem?
    private weak var emailValidationContainer: UIView?
    private weak var passwordMismatchContainer: UIView?
    private weak var emailContainerStack: UIStackView?
    private weak var passwordContainerStack: UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        let loginHeader = UIImage(resource: .loginHeader)
        let loginHeaderImageView = UIImageView(image: loginHeader)
        loginHeaderImageView.contentMode = .scaleAspectFill
        loginHeaderImageView.clipsToBounds = true
        loginHeaderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        signUpButton.backgroundColor = .black
        signUpButton.tintColor = .white
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        signUpButton.layer.cornerRadius = 16
        signUpButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false

        signUpSpinner.translatesAutoresizingMaskIntoConstraints = false
        signUpSpinner.hidesWhenStopped = true
        signUpSpinner.color = .white
        signUpButton.addSubview(signUpSpinner)
        
        let nameField = RoundedTextField(originalText: "Name")
        let mailField = RoundedTextField(originalText: "E-Mail Address*", isEmailField: true)
        let passwordField = RoundedTextField(originalText: "Password*", isSecuredTextField: true, isPasswordField: true)
        let repeatPasswordField = RoundedTextField(originalText: "Confirm Password*", isSecuredTextField: true, isPasswordField: true)
        self.nameField = nameField
        self.emailField = mailField
        self.passwordField = passwordField
        self.repeatPasswordField = repeatPasswordField

        let emailValidationContainer = makeInsetErrorContainer(for: emailValidationLabel)
        self.emailValidationContainer = emailValidationContainer
        let emailContainer = UIStackView(arrangedSubviews: [mailField, emailValidationContainer])
        emailContainer.axis = .vertical
        emailContainer.spacing = 0
        emailContainer.alignment = .fill
        self.emailContainerStack = emailContainer

        let passwordMismatchContainer = makeInsetErrorContainer(for: passwordMismatchLabel)
        self.passwordMismatchContainer = passwordMismatchContainer
        let confirmPasswordContainer = UIStackView(arrangedSubviews: [repeatPasswordField, passwordMismatchContainer])
        confirmPasswordContainer.axis = .vertical
        confirmPasswordContainer.spacing = 0
        confirmPasswordContainer.alignment = .fill
        self.passwordContainerStack = confirmPasswordContainer

        // Start in compact layout; expand only when a validation message is shown.
        setErrorContainer(emailValidationContainer, visible: false)
        setErrorContainer(passwordMismatchContainer, visible: false)
        
        let stack = UIStackView(arrangedSubviews: [nameField, emailContainer, passwordField, confirmPasswordContainer])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        mailField.onRawTextChanged = { [weak self] _ in
            self?.updateEmailValidationState()
        }

        passwordField.onRawTextChanged = { [weak self] _ in
            self?.updatePasswordMismatchState()
        }

        repeatPasswordField.onRawTextChanged = { [weak self] _ in
            self?.updatePasswordMismatchState()
        }
        
        view.addSubview(loginHeaderImageView)
        view.addSubview(stack)
        view.addSubview(signUpButton)

        let headerAspectRatio = loginHeader.size.height / loginHeader.size.width
        
        NSLayoutConstraint.activate([
            loginHeaderImageView.topAnchor.constraint(equalTo: view.topAnchor),
            loginHeaderImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginHeaderImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginHeaderImageView.heightAnchor.constraint(equalTo: loginHeaderImageView.widthAnchor, multiplier: headerAspectRatio),
            
            stack.topAnchor.constraint(equalTo: loginHeaderImageView.bottomAnchor, constant: 34),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            signUpButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 32),
            signUpButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            signUpSpinner.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            signUpSpinner.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor)
        ])
    }
    
    @objc private func didTapButton() {
        hasAttemptedSubmit = true
        view.endEditing(true)
        updateEmailValidationState()
        updatePasswordMismatchState()

        guard isFormValid else {
            return
        }

        setLoadingState(isLoading: true)

        viewModel.submit(name: nameField?.rawText ?? "", email: emailField?.rawText ?? "")

        pendingSignUpWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.setLoadingState(isLoading: false)
            self.navigateToNextScreen()
        }
        pendingSignUpWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }

    private func updatePasswordMismatchState() {
        guard hasAttemptedSubmit else {
            passwordMismatchLabel.isHidden = true
            setErrorContainer(passwordMismatchContainer, visible: false)
            passwordContainerStack?.spacing = 0
            return
        }

        guard let passwordField, let repeatPasswordField else {
            passwordMismatchLabel.isHidden = true
            return
        }

        let password = passwordField.rawText
        let repeatedPassword = repeatPasswordField.rawText
        let isInvalid = !viewModel.doPasswordsMatch(password: password, repeatPassword: repeatedPassword)
        passwordMismatchLabel.isHidden = !isInvalid
        setErrorContainer(passwordMismatchContainer, visible: isInvalid)
        passwordContainerStack?.spacing = isInvalid ? 8 : 0
    }

    private func updateEmailValidationState() {
        guard hasAttemptedSubmit else {
            emailValidationLabel.isHidden = true
            setErrorContainer(emailValidationContainer, visible: false)
            emailContainerStack?.spacing = 0
            return
        }

        guard let emailField else {
            emailValidationLabel.isHidden = true
            return
        }

        let isValid = viewModel.isEmailValid(emailField.rawText)
        let shouldShowError = !isValid
        emailValidationLabel.isHidden = !shouldShowError
        setErrorContainer(emailValidationContainer, visible: shouldShowError)
        emailContainerStack?.spacing = shouldShowError ? 8 : 0
    }

    private var isFormValid: Bool {
        guard let emailField, let passwordField, let repeatPasswordField else {
            return false
        }

        let emailValue = emailField.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmailValid = viewModel.isEmailValid(emailValue)

        let password = passwordField.rawText
        let repeatedPassword = repeatPasswordField.rawText
        let doPasswordsMatch = viewModel.doPasswordsMatch(password: password, repeatPassword: repeatedPassword)

        return isEmailValid && doPasswordsMatch
    }

    private func setLoadingState(isLoading: Bool) {
        signUpButton.isEnabled = !isLoading
        signUpButton.setTitle(isLoading ? "" : "Sign up", for: .normal)
        signUpButton.alpha = isLoading ? 0.65 : 1.0

        if isLoading {
            signUpSpinner.startAnimating()
        } else {
            signUpSpinner.stopAnimating()
        }

        let fields = [nameField, emailField, passwordField, repeatPasswordField]
        fields.forEach { field in
            field?.isUserInteractionEnabled = !isLoading
        }
    }

    private func navigateToNextScreen() {
        let nextViewController = HomeViewController()
        if let navigationController {
            navigationController.pushViewController(nextViewController, animated: true)
        } else {
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: true)
        }
    }

    deinit {
        pendingSignUpWorkItem?.cancel()
    }

    private func makeInsetErrorContainer(for label: UILabel) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: fieldTextInset),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func setErrorContainer(_ container: UIView?, visible: Bool) {
        guard let container else { return }

        let targetHeight: CGFloat = visible ? 16 : 0
        container.constraints.first(where: { $0.firstAttribute == .height })?.constant = targetHeight
    }
}
