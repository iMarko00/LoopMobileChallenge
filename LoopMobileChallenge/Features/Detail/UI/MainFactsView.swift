//
//  MainFactsView.swift
//  LoopMobileChallenge
//
//  Created by Marko Misic on 11.08.26.
//

import Foundation
import UIKit

final class MainFactsView: UIView {
    private let mainFactsView = UIStackView()
    private let starRatingView = StarRatingView(bigStar: true)
    private let releaseDateAndRunTimeLabel = UILabel()
    private let titleAndReleaseYearLabel = UILabel()
    private var genresCollectionHeightConstraint: NSLayoutConstraint?
    
    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        super.init(frame: .zero)
        setupUI()
        setupLabels()
        starRatingView.configure(with: movie.rating)
        genresCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels() {
        releaseDateAndRunTimeLabel.text = "\(cleanUpReleaseDate(date: movie.releaseDate)) · \(cleanedUpDuration(duration: movie.runtime))"
        releaseDateAndRunTimeLabel.textAlignment = .center
        
        titleAndReleaseYearLabel.text = "\(movie.title) (\(movie.releaseDate.prefix(4)))"
        titleAndReleaseYearLabel.textAlignment = .center
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainFactsView)
        
        mainFactsView.addArrangedSubview(starRatingView)
        mainFactsView.addArrangedSubview(releaseDateAndRunTimeLabel)
        mainFactsView.addArrangedSubview(titleAndReleaseYearLabel)
        mainFactsView.addArrangedSubview(genresCollectionView)
        
        mainFactsView.axis = .vertical
        mainFactsView.spacing = 4
        mainFactsView.alignment = .fill
        mainFactsView.translatesAutoresizingMaskIntoConstraints = false
        genresCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let collectionHeightConstraint = genresCollectionView.heightAnchor.constraint(equalToConstant: 1)
        genresCollectionHeightConstraint = collectionHeightConstraint
        
        NSLayoutConstraint.activate([
            mainFactsView.topAnchor.constraint(equalTo: topAnchor),
            mainFactsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainFactsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainFactsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionHeightConstraint
        ])
    }
    
    private func cleanUpReleaseDate(date: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM.yyyy"
        
        guard let date = inputFormatter.date(from: date) else {
            return ""
        }
        
        return outputFormatter.string(from: date)
    }
    
    private func cleanedUpDuration(duration: Int) -> String {
        String(
            format: "%02d:%02d",
            Int(duration / 60),
            Int(duration.remainderReportingOverflow(dividingBy: 60).partialValue)
        )
    }
    
    private lazy var genresCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.register(
            GenreCell.self,
            forCellWithReuseIdentifier: String(describing: GenreCell.self)
        )

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear

        return collectionView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGenresCollectionHeight()
    }

    private func updateGenresCollectionHeight() {
        genresCollectionView.layoutIfNeeded()
        let contentHeight = genresCollectionView.collectionViewLayout.collectionViewContentSize.height

        guard contentHeight > 0,
              genresCollectionHeightConstraint?.constant != contentHeight else {
            return
        }

        genresCollectionHeightConstraint?.constant = contentHeight
    }
}

extension MainFactsView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let genre = movie.genres[indexPath.item]

        let font = UIFont.systemFont(ofSize: 14, weight: .light)
        let textWidth = (genre as NSString).size(withAttributes: [
            .font: font
        ]).width

        let horizontalPadding: CGFloat = 16

        return CGSize(
            width: ceil(textWidth) + horizontalPadding,
            height: 21
        )
    }
}

extension MainFactsView: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        movie.genres.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: GenreCell.self),
            for: indexPath
        ) as? GenreCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: movie.genres[indexPath.item])

        return cell
    }
}
