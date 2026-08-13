//
//  OverviewSectionView.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 11.08.26.
//

import Foundation
import UIKit

final class OverviewSectionView: UIView {
    let overviewView = UIStackView()
    let overviewLabel = UILabel()
    let movieDescription = UILabel()
    var overview: String
    
    init(overview: String) {
        self.overview = overview
        super.init(frame: .zero)
        setupLabels()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels() {
        overviewLabel.font = .systemFont(ofSize: 16, weight: .bold)
        overviewLabel.textColor = .black
        overviewLabel.text = "Overview"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        movieDescription.attributedText = NSAttributedString(
            string: overview,
            attributes: [
                .paragraphStyle: paragraphStyle
            ]
        )
        movieDescription.font = .systemFont(ofSize: 16, weight: .light)
        movieDescription.textColor = UIColor(red: 20 / 255, green: 28 / 255, blue: 37 / 255, alpha: 0.7)
        movieDescription.numberOfLines = 0
    }
    
    private func setupUI() {
        overviewView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overviewView)
        
        overviewView.addArrangedSubview(overviewLabel)
        overviewView.addArrangedSubview(movieDescription)
        
        overviewView.axis = .vertical
        overviewView.spacing = 16
        overviewView.alignment = .fill
        overviewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            overviewView.topAnchor.constraint(equalTo: topAnchor),
            overviewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overviewView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overviewView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
