//
//  KeyFactsGridView.swift
//  LoopMobileChallenge
//
//  Created by GitHub Copilot on 13.08.26.
//

import Foundation
import UIKit

struct KeyFactsGridItem {
    let title: String
    let value: String
}

public enum Constants {
    static let columns: CGFloat = 2
    static let interitemSpacing: CGFloat = 12
    static let lineSpacing: CGFloat = 12
    static let cellHeight: CGFloat = 66
    static let collectionHeight: CGFloat = 180
    static let cellCornerRadius: CGFloat = 12
    static let titleSpacing: CGFloat = 2
}

final class KeyFactsGridView: UIView {

    private var items: [KeyFactsGridItem] = []

    private var keyFactsLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.interitemSpacing
        layout.minimumLineSpacing = Constants.lineSpacing
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            KeyFactsGridCell.self,
            forCellWithReuseIdentifier: String(describing: KeyFactsGridCell.self)
        )

        return collectionView
    }()

    init(items: [KeyFactsGridItem]) {
        self.items = Array(items.prefix(4))
        super.init(frame: .zero)
        setupLabel()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        keyFactsLabel.translatesAutoresizingMaskIntoConstraints = false
        keyFactsLabel.font = .systemFont(ofSize: 16, weight: .bold)
        keyFactsLabel.textColor = .black
        keyFactsLabel.text = "Key Facts"
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyFactsLabel)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            keyFactsLabel.topAnchor.constraint(equalTo: topAnchor),
            keyFactsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            keyFactsLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: keyFactsLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: Constants.collectionHeight)
        ])
    }
}

extension KeyFactsGridView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: KeyFactsGridCell.self),
            for: indexPath
        ) as? KeyFactsGridCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: items[indexPath.item])

        return cell
    }
}

extension KeyFactsGridView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellWidth = floor(
            (collectionView.bounds.width - Constants.interitemSpacing) / Constants.columns
        )

        return CGSize(width: cellWidth, height: Constants.cellHeight)
    }
}

private final class KeyFactsGridCell: UICollectionViewCell {
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: KeyFactsGridItem) {
        titleLabel.text = item.title
        valueLabel.text = item.value
        accessibilityLabel = "\(item.title), \(item.value)"
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor(red: 20 / 255, green: 28 / 255, blue: 37 / 255, alpha: 0.05)
        contentView.layer.cornerRadius = Constants.cellCornerRadius
        contentView.layer.masksToBounds = true

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Constants.titleSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 8,
            leading: 12,
            bottom: 14,
            trailing: 12
        )

        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = UIColor(red: 20 / 255, green: 28 / 255, blue: 37 / 255, alpha: 0.7)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        valueLabel.font = .systemFont(ofSize: 16, weight: .light)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.adjustsFontForContentSizeCategory = true

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        isAccessibilityElement = true
    }
}
