import UIKit

enum TapInteractionFeedback {
    static func darkenFlash(on view: UIView, completion: (() -> Void)? = nil) {
        let overlay = UIView(frame: view.bounds)
        overlay.translatesAutoresizingMaskIntoConstraints = true
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = .black
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = false
        overlay.layer.cornerRadius = view.layer.cornerRadius
        overlay.layer.masksToBounds = true

        view.addSubview(overlay)

        UIView.animate(withDuration: 0.08, animations: {
            overlay.alpha = 0.12
        }) { _ in
            UIView.animate(withDuration: 0.12, animations: {
                overlay.alpha = 0
            }) { _ in
                overlay.removeFromSuperview()
                completion?()
            }
        }
    }

    static func pulseExpand(on view: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.08,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                view.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.14,
                delay: 0,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: {
                    view.transform = .identity
                }
            ) { _ in
                completion?()
            }
        }
    }
}
