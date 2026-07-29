//
//  ViewController.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 29.07.26.
//

import UIKit

// TODO: Rename to smth like SignUpVC
class ViewController: UIViewController {
    
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
        
        let signUpButton = UIButton(type: .roundedRect)
        signUpButton.backgroundColor = .black
        signUpButton.tintColor = .white
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        signUpButton.layer.cornerRadius = 16
        signUpButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        let nameField = RoundedTextField(originalText: "Name")
        let mailField = RoundedTextField(originalText: "E-Mail Address*")
        let passwordField = RoundedTextField(originalText: "Password*", isSecuredTextField: true)
        let repeatPasswordField = RoundedTextField(originalText: "Confirm Password*", isSecuredTextField: true)
        
        let stack = UIStackView(arrangedSubviews: [nameField, mailField, passwordField, repeatPasswordField])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
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
            signUpButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func didTapButton() {
        // Navigate to new VC
        let alert = UIAlertController(title: "Tapped", message: "Button action works.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
