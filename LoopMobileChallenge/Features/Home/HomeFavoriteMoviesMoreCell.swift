//
//  HomeFavoriteMoviesMoreCell.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 09.08.26.
//

import Foundation
import UIKit

final class HomeFavoriteMoviesMoreCell: UICollectionViewCell {
    private let moreButton = UIButton()
    private let highlightLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = moreButton.bounds.height / 2
        
        moreButton.layer.shadowPath = UIBezierPath(
            roundedRect: moreButton.bounds,
            cornerRadius: radius
        ).cgPath
        
        highlightLayer.frame = moreButton.frame
        highlightLayer.shadowPath = UIBezierPath(
            roundedRect: moreButton.bounds,
            cornerRadius: radius
        ).cgPath
    }
    
    private func setupUI() {
        var config = UIButton.Configuration.plain()
        config.title = "See all →"
        config.attributedTitle = AttributedString("See all →", attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 14, weight: .heavy)]))
        config.baseForegroundColor = .black
        config.background.backgroundColor = .white
        config.background.cornerRadius = 22
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        
        moreButton.configuration = config
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        moreButton.layer.shadowColor = UIColor.black.cgColor
        moreButton.layer.shadowOpacity = 0.5
        moreButton.layer.shadowRadius = 5
        moreButton.layer.shadowOffset = CGSize(width: 3, height: 4)
        
        moreButton.layer.borderWidth = 0.8
        moreButton.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        moreButton.layer.masksToBounds = false
        moreButton.clipsToBounds = false
        
        highlightLayer.shadowColor = UIColor.white.cgColor
        highlightLayer.shadowOpacity = 0.8
        highlightLayer.shadowRadius = 3
        highlightLayer.shadowOffset = CGSize(width: 0, height: -2)
        
        contentView.addSubview(moreButton)
        contentView.layer.insertSublayer(highlightLayer, below: moreButton.layer)
        
        NSLayoutConstraint.activate([
            moreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
