//
//  GenreCell.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 11.08.26.
//

import Foundation
import UIKit

final class GenreCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .black
        label.textAlignment = .center

        contentView.backgroundColor = UIColor(red: 20 / 255.0, green: 28 / 255.0, blue: 37 / 255.0, alpha: 0.05)
        contentView.layer.cornerRadius = 11

        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with genre: String) {
        label.text = genre
    }
}
