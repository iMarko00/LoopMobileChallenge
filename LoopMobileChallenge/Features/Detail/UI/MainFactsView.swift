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
    private let starRatingView = StarRatingView(bigStar: true, contentAlignment: .center)
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
        releaseDateAndRunTimeLabel.font = .preferredFont(forTextStyle: .body)
        releaseDateAndRunTimeLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        titleAndReleaseYearLabel.attributedText = createAttributedString(
            title: movie.title,
            releaseDate: movie.releaseDate
        )
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
        mainFactsView.spacing = 12
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
    
    private func createAttributedString(title: String, releaseDate: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: title,
            attributes: [.font: UIFont(name: "SFProText-Bold", size: 24) ?? .systemFont(ofSize: 24, weight: .bold)]
        )
        attributedText.append(
            NSAttributedString(
                string: "(\(releaseDate.prefix(4)))",
                attributes: [.font: UIFont(name: "SFProText-Light", size: 24) ?? .systemFont(ofSize: 24, weight: .light), .foregroundColor: UIColor(red: 20 / 255.0, green: 28 / 255.0, blue: 37 / 255.0, alpha: 0.7)]
            )
        )
        return attributedText
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
            format: "%dh %dm",
            Int(duration / 60),
            Int(duration.remainderReportingOverflow(dividingBy: 60).partialValue)
        )
    }
    
    private lazy var genresCollectionView: UICollectionView = {
        let layout = CenteredRowFlowLayout()
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        layout.sectionInset = .zero

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

        let horizontalPadding: CGFloat = 20

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
