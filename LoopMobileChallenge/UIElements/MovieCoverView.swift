import UIKit

final class MovieCoverView: UIView {
    private let drawsShadow: Bool
	private static let imageCache = NSCache<NSURL, UIImage>()

	private let imageView = UIImageView()
	private var imageLoadTask: Task<Void, Never>?

    init(frame: CGRect = .zero, drawsShadow: Bool = true) {
        self.drawsShadow = drawsShadow
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        self.drawsShadow = true
        super.init(coder: coder)
        setupUI()
    }

	deinit {
		imageLoadTask?.cancel()
	}

	func configure(posterURLString: String?) {
		imageLoadTask?.cancel()
		imageView.image = nil

		guard let posterURLString,
			  let url = URL(string: posterURLString) else {
			imageView.backgroundColor = .secondarySystemBackground
			return
		}

		if let cachedImage = Self.imageCache.object(forKey: url as NSURL) {
			imageView.backgroundColor = .clear
			imageView.image = cachedImage
			return
		}

		imageView.backgroundColor = .secondarySystemBackground
		imageLoadTask = Task { [weak self] in
			do {
				let (data, response) = try await URLSession.shared.data(from: url)
				guard !Task.isCancelled,
					  let httpResponse = response as? HTTPURLResponse,
					  (200...299).contains(httpResponse.statusCode),
					  let image = UIImage(data: data) else {
					return
				}

				Self.imageCache.setObject(image, forKey: url as NSURL)
				self?.imageView.backgroundColor = .clear
				self?.imageView.image = image
			} catch {
				guard !Task.isCancelled else { return }
			}
		}
	}

	func resetForReuse() {
		imageLoadTask?.cancel()
		imageView.image = nil
		imageView.backgroundColor = .secondarySystemBackground
	}
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard drawsShadow else { return }

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 14
        ).cgPath
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        layer.masksToBounds = false
        
        if drawsShadow {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.30
            layer.shadowRadius = 10
            layer.shadowOffset = CGSize(width: 0, height: 5)
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        imageView.layer.cornerCurve = .continuous
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
