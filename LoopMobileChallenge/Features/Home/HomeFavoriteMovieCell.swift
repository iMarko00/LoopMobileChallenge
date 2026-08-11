import UIKit

final class HomeFavoriteMovieCell: UICollectionViewCell {
    private let coverView = MovieCoverView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with movie: Movie) {
        coverView.configure(posterURLString: movie.posterUrl)
    }

    func configurePlaceholder() {
        coverView.configure(posterURLString: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverView.resetForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cardFrame = coverView.frame
        let shadowBand = CGRect(
            x: cardFrame.minX + 12,
            y: cardFrame.maxY + 1,
            width: max(0, cardFrame.width - 28),
            height: 7
        )

        layer.shadowPath = UIBezierPath(
            roundedRect: shadowBand,
            cornerRadius: 6
        ).cgPath
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false
        backgroundColor = .clear
        coverView.isUserInteractionEnabled = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.26
        layer.shadowRadius = 7
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false

        contentView.addSubview(coverView)

        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
