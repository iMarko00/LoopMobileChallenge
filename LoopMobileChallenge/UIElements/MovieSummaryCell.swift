import UIKit

final class MovieSummaryCell: UITableViewCell {
    
    private let coverView = MovieCoverView(drawsShadow: false)
    private let yearLabel = UILabel()
    private let titleLabel = UILabel()
    private let favoriteBadge = FavoriteBadge()
    private let infoStackView = UIStackView()
    private let hStackView = UIStackView()
    private let starRatingView = StarRatingView()
    private var currentMovieID: Int?
    private var hStackLeadingConstraint: NSLayoutConstraint?
    private var hStackTrailingConstraint: NSLayoutConstraint?

    var horizontalContentInset: CGFloat = 0 {
        didSet {
            hStackLeadingConstraint?.constant = horizontalContentInset
            hStackTrailingConstraint?.constant = -horizontalContentInset
        }
    }

    var onFavoriteToggle: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with movie: Movie, isFavorite: Bool) {
        currentMovieID = movie.id
        yearLabel.text = String(movie.releaseDate.prefix(4))
        titleLabel.text = movie.title
        coverView.configure(posterURLString: movie.posterUrl)
        favoriteBadge.isFavorite = isFavorite
        starRatingView.configure(with: movie.rating)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverView.resetForReuse()
        yearLabel.text = nil
        titleLabel.text = nil
        currentMovieID = nil
        onFavoriteToggle = nil
        favoriteBadge.isFavorite = false
        horizontalContentInset = 0
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
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail

        hStackView.axis = .horizontal
        hStackView.spacing = 8
        hStackView.alignment = .center
        hStackView.translatesAutoresizingMaskIntoConstraints = false

        infoStackView.axis = .vertical
        infoStackView.spacing = 4
        infoStackView.alignment = .leading
        infoStackView.translatesAutoresizingMaskIntoConstraints = false

        favoriteBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        favoriteBadge.setContentHuggingPriority(.required, for: .horizontal)
        favoriteBadge.addTarget(self, action: #selector(didTapFavoriteBadge), for: .valueChanged)

        contentView.addSubview(hStackView)

        infoStackView.addArrangedSubview(yearLabel)
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(starRatingView)

        hStackView.addArrangedSubview(coverView)
        hStackView.setCustomSpacing(27, after: coverView)
        hStackView.addArrangedSubview(infoStackView)
        hStackView.addArrangedSubview(favoriteBadge)
        hStackView.setCustomSpacing(8, after: infoStackView)

        infoStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        infoStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Cap the title line width to the design target when space allows
        let titleTargetWidth = titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 220.5)
        titleTargetWidth.priority = .required
        titleTargetWidth.isActive = true

        hStackLeadingConstraint = hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        hStackTrailingConstraint = hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)

        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            hStackLeadingConstraint!,
            hStackTrailingConstraint!,
            hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            coverView.widthAnchor.constraint(equalToConstant: 64),
            coverView.heightAnchor.constraint(equalToConstant: 89),

            favoriteBadge.widthAnchor.constraint(equalToConstant: 18),
            favoriteBadge.heightAnchor.constraint(equalToConstant: 18)
        ])

        horizontalContentInset = 0
    }

    @objc private func didTapFavoriteBadge() {
        guard let currentMovieID else { return }
        onFavoriteToggle?(currentMovieID)
    }
}
