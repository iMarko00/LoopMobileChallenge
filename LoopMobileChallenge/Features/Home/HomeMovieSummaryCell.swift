import UIKit

final class HomeMovieSummaryCell: UITableViewCell {
    private let idLabel = UILabel()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with movie: Movie) {
        idLabel.text = "ID: \(movie.id)"
        titleLabel.text = "Title: \(movie.title)"
        overviewLabel.text = "Overview: \(movie.overview)"
    }

    private func setupUI() {
        selectionStyle = .none

        idLabel.font = .preferredFont(forTextStyle: .caption1)
        idLabel.textColor = .secondaryLabel
        idLabel.numberOfLines = 1

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        overviewLabel.font = .preferredFont(forTextStyle: .subheadline)
        overviewLabel.textColor = .secondaryLabel
        overviewLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        stackView.addArrangedSubview(idLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(overviewLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
