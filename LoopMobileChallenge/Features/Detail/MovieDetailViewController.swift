//
//  MovieDetailViewController.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 09.08.26.
//

import Foundation
import UIKit

final class MovieDetailViewController: UIViewController {
    
    private let viewModel: DetailViewModel
    private let coverView = MovieCoverView()
    private let mainFactsView: MainFactsView

    private let favoriteButton = UIButton(type: .system)
    private let dismissButton = UIButton(type: .system)
    
    init(movie: Movie) {
        self.viewModel = DetailViewModel(
            movie: movie,
            favoritesManager: FavoritesManager()
        )
        self.mainFactsView = MainFactsView(movie: movie)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coverView.configure(posterURLString: viewModel.moviePoserUrl)
        updateFavoriteButtonImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderButtonShapes()
    }
    
    private func setupUI() {
        view.addSubview(coverView)
        view.addSubview(mainFactsView)
        
        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 30
            ),
            coverView.widthAnchor.constraint(equalToConstant: 203),
            coverView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coverView.heightAnchor.constraint(equalToConstant: 295.5),
            
            mainFactsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainFactsView.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 18.5),
            mainFactsView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainFactsView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func configureButtons() {
        configureAsGlassButton(favoriteButton)
        configureAsGlassButton(dismissButton)

        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            dismissButton.widthAnchor.constraint(equalToConstant: 44),
            dismissButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        updateFavoriteButtonImage()
        favoriteButton.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)

        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.accessibilityLabel = "Dismiss"
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }

    private func configureAsGlassButton(_ button: UIButton) {
        var config = UIButton.Configuration.glass()
        config.cornerStyle = .capsule
        config.contentInsets = .zero
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
    }

    private func updateHeaderButtonShapes() {
        [favoriteButton, dismissButton].forEach { button in
            button.layer.cornerRadius = button.bounds.height / 2
            button.layer.masksToBounds = true
        }
    }

    private func updateFavoriteButtonImage() {
        let isFavorite = viewModel.isFavorite
        let imageName = isFavorite ? "ImgFavoriteBadeSelected" : "ImgFavoriteBadeNotSelected"
        favoriteButton.setImage(UIImage(named: imageName), for: .normal)
        favoriteButton.accessibilityLabel = isFavorite ? "Remove from favorites" : "Add to favorites"
        favoriteButton.accessibilityValue = isFavorite ? "Selected" : "Not selected"
    }

    @objc private func didTapFavoriteButton() {
        viewModel.toggleFavorite()
        updateFavoriteButtonImage()
    }

    @objc private func didTapDismissButton() {
        if let navigationController {
            // If this screen is pushed, pop it.
            if navigationController.viewControllers.first !== self {
                navigationController.popViewController(animated: true)
                return
            }
            
            // If this screen is the root of a presented navigation controller, dismiss it.
            if navigationController.presentingViewController != nil {
                navigationController.dismiss(animated: true)
                return
            }
        }

        // Fallback for direct modal presentation.
        dismiss(animated: true)
    }
}
