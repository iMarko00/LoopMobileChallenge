import UIKit

final class ScrollSoftEdgeEffect {
    private let height: CGFloat

    private let topView = UIView()
    private let bottomView = UIView()
    private let topLayer = CAGradientLayer()
    private let bottomLayer = CAGradientLayer()

    private weak var scrollView: UIScrollView?
    private weak var containerView: UIView?

    private var contentOffsetObservation: NSKeyValueObservation?
    private var contentSizeObservation: NSKeyValueObservation?
    private var boundsObservation: NSKeyValueObservation?

    init(height: CGFloat = 20) {
        self.height = height
    }

    deinit {
        contentOffsetObservation?.invalidate()
        contentSizeObservation?.invalidate()
        boundsObservation?.invalidate()
    }

    func install(on scrollView: UIScrollView, in containerView: UIView) {
        self.scrollView = scrollView
        self.containerView = containerView

        setupViewsIfNeeded()
        setupConstraints(scrollView: scrollView, containerView: containerView)
        updateColors()
        startObserving(scrollView: scrollView)
        updateFrames()
        updateVisibility()
    }

    func updateFrames() {
        topLayer.frame = topView.bounds
        bottomLayer.frame = bottomView.bounds
    }

    func updateColors() {
        guard let containerView else { return }

        let baseColor = (containerView.backgroundColor ?? .systemBackground)
            .resolvedColor(with: containerView.traitCollection)

        topLayer.colors = [baseColor.cgColor, baseColor.withAlphaComponent(0).cgColor]
        topLayer.locations = [0, 1]

        bottomLayer.colors = [baseColor.withAlphaComponent(0).cgColor, baseColor.cgColor]
        bottomLayer.locations = [0, 1]
    }

    func updateVisibility() {
        guard let scrollView else { return }

        let topOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let maxOffset = max(
            0,
            scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
        )

        topView.alpha = topOffset > 0.5 ? 1 : 0
        bottomView.alpha = topOffset < (maxOffset - 0.5) ? 1 : 0
    }

    private func setupViewsIfNeeded() {
        guard topView.superview == nil, bottomView.superview == nil else { return }

        topView.isUserInteractionEnabled = false
        bottomView.isUserInteractionEnabled = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false

        topView.layer.addSublayer(topLayer)
        bottomView.layer.addSublayer(bottomLayer)
    }

    private func setupConstraints(scrollView: UIScrollView, containerView: UIView) {
        guard topView.superview == nil, bottomView.superview == nil else { return }

        containerView.addSubview(topView)
        containerView.addSubview(bottomView)

        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: height),

            bottomView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    private func startObserving(scrollView: UIScrollView) {
        contentOffsetObservation?.invalidate()
        contentSizeObservation?.invalidate()
        boundsObservation?.invalidate()

        contentOffsetObservation = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            self?.updateVisibility()
        }

        contentSizeObservation = scrollView.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            self?.updateVisibility()
        }

        boundsObservation = scrollView.observe(\.bounds, options: [.new]) { [weak self] _, _ in
            self?.updateVisibility()
            self?.updateFrames()
        }
    }
}
