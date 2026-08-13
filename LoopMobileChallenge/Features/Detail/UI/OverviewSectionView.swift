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
    
    init() {
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
        
        movieDescription.font = .systemFont(ofSize: 16, weight: .light)
        movieDescription.textColor = UIColor(red: 20 / 255, green: 28 / 255, blue: 37 / 255, alpha: 0.7)
        movieDescription.numberOfLines = 0
        movieDescription.text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum."
    }
    
    private func setupUI() {
        overviewView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overviewView)
        
        overviewView.addArrangedSubview(overviewLabel)
        overviewView.addArrangedSubview(movieDescription)
        
        overviewView.axis = .vertical
        overviewView.spacing = 4
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
