//
//  StarRatingView.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 03.08.26.
//

import Foundation
import UIKit
// bigger star review UI for the DetailScreen
final class StarRatingView: UIView {
    private let filledStarColor = UIColor(red: 253.0 / 255.0, green: 158.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0)
    private let emptyStarColor = UIColor(red: 20.0 / 255.0, green: 28.0 / 255.0, blue: 37.0 / 255.0, alpha: 0.1)
    
    private let starsStackView = UIStackView()
    private var starImageViews: [UIImageView] = []
    
    private var bigStar: Bool = false
    private var starWidth: CGFloat {
        bigStar ? 16 : 12
    }
    private var starHeight: CGFloat {
        bigStar ? 14 : 12
    }

    init(frame: CGRect = .zero, bigStar: Bool = false) {
        self.bigStar = bigStar
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(with rating: Double) {
        updateStars(for: rating)
    }
    
    private func setupUI() {
        guard starsStackView.superview == nil else { return }

        translatesAutoresizingMaskIntoConstraints = false
        starsStackView.axis = .horizontal
        starsStackView.spacing = 2
        starsStackView.alignment = .center
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        starsStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        starsStackView.setContentHuggingPriority(.required, for: .horizontal)

        addSubview(starsStackView)
        NSLayoutConstraint.activate([
            starsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            starsStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = emptyStarColor
            starImageView.image = UIImage(systemName: "star.fill")
            starImageViews.append(starImageView)
            starsStackView.addArrangedSubview(starImageView)
            
            NSLayoutConstraint.activate([
                starImageView.widthAnchor.constraint(equalToConstant: starWidth),
                starImageView.heightAnchor.constraint(equalToConstant: starHeight)
            ])
        }

        updateStars(for: 0)
    }
    
    private func updateStars(for rating: Double) {
        // Ratings are 0...10 in payload, map to 0...5 stars
        let filledStars = max(0, min(5, Int((rating / 2.0).rounded())))

        for (index, starImageView) in starImageViews.enumerated() {
            starImageView.tintColor = index < filledStars ? filledStarColor : emptyStarColor
        }
    }
}
