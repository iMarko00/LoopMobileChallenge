import UIKit

final class FavoriteBadge: UIControl {
	private let imageView = UIImageView()

	var isFavorite: Bool = false {
		didSet {
			updateAppearance()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}

	private func setupUI() {
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .clear
		accessibilityTraits = .button

		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = false

		addSubview(imageView)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: topAnchor),
			imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		addTarget(self, action: #selector(didTapSelf), for: .touchUpInside)
		updateAppearance()
	}

	private func updateAppearance() {
		let imageName = isFavorite ? "ImgFavoriteBadeSelected" : "ImgFavoriteBadeNotSelected"
		imageView.image = UIImage(named: imageName)
		accessibilityLabel = isFavorite ? "Remove from favorites" : "Add to favorites"
		accessibilityValue = isFavorite ? "Selected" : "Not selected"
	}

	@objc private func didTapSelf() {
		sendActions(for: .valueChanged)
	}
}
