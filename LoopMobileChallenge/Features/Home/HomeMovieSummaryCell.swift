import UIKit

final class HomeMovieSummaryCell: UITableViewCell {
    private let filledStarColor = UIColor(red: 253.0 / 255.0, green: 158.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0)
    private let emptyStarColor = UIColor(red: 20.0 / 255.0, green: 28.0 / 255.0, blue: 37.0 / 255.0, alpha: 0.1)

    private let coverView = MovieCoverView()
    private let yearLabel = UILabel()
    private let titleLabel = UILabel()
    private let starsStackView = UIStackView()
    private let favoriteImageView = UIImageView()
    private let infoStackView = UIStackView()
    private let hStackView = UIStackView()
    private var starImageViews: [UIImageView] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with movie: Movie) {
        yearLabel.text = String(movie.releaseDate.prefix(4))
        titleLabel.text = movie.title
        coverView.configure(posterURLString: movie.posterUrl)
        updateStars(for: movie.rating)
        updateBookmarkIcon()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverView.resetForReuse()
        yearLabel.text = nil
        titleLabel.text = nil
        updateStars(for: 0)
        updateBookmarkIcon()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateBookmarkIcon()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        coverView.layer.cornerRadius = 10

        yearLabel.font = UIFont(name: "SFProText-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        yearLabel.textColor = .secondaryLabel
        yearLabel.numberOfLines = 1

        titleLabel.font = UIFont(name: "SFProDisplay-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.lineBreakMode = .byTruncatingTail

        hStackView.axis = .horizontal
        hStackView.spacing = 8
        hStackView.alignment = .center
        hStackView.translatesAutoresizingMaskIntoConstraints = false

        infoStackView.axis = .vertical
        infoStackView.spacing = 4
        infoStackView.alignment = .fill
        infoStackView.translatesAutoresizingMaskIntoConstraints = false

        starsStackView.axis = .horizontal
        starsStackView.spacing = 2
        starsStackView.alignment = .center
        starsStackView.translatesAutoresizingMaskIntoConstraints = false

        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = emptyStarColor
            starImageView.image = UIImage(systemName: "star.fill")
            starImageViews.append(starImageView)
            starsStackView.addArrangedSubview(starImageView)

            NSLayoutConstraint.activate([
                starImageView.widthAnchor.constraint(equalToConstant: 12),
                starImageView.heightAnchor.constraint(equalToConstant: 12)
            ])
        }

        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.image = UIImage(systemName: "bookmark")
        favoriteImageView.tintColor = .label
        favoriteImageView.contentMode = .scaleAspectFit
        favoriteImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        favoriteImageView.setContentHuggingPriority(.required, for: .horizontal)

        let spacerView = UIView()
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        contentView.addSubview(hStackView)

        infoStackView.addArrangedSubview(yearLabel)
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(starsStackView)

        hStackView.addArrangedSubview(coverView)
        hStackView.setCustomSpacing(27, after: coverView)
        hStackView.addArrangedSubview(infoStackView)
        hStackView.addArrangedSubview(spacerView)
        hStackView.addArrangedSubview(favoriteImageView)

        infoStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        infoStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            coverView.widthAnchor.constraint(equalToConstant: 64),
            coverView.heightAnchor.constraint(equalToConstant: 89),

            favoriteImageView.widthAnchor.constraint(equalToConstant: 13.5),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 19)
        ])
    }

    private func updateStars(for rating: Double) {
        // Ratings are 0...10 in payload, map to 0...5 stars.
        let filledStars = max(0, min(5, Int((rating / 2.0).rounded())))

        for (index, starImageView) in starImageViews.enumerated() {
            starImageView.tintColor = index < filledStars ? filledStarColor : emptyStarColor
        }
    }

    private func updateBookmarkIcon() {
        let symbolName = isSelected ? "bookmark.fill" : "bookmark"
        favoriteImageView.image = UIImage(systemName: symbolName)
    }
}
