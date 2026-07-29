import UIKit

/// A reusable text field with rounded corners, drop shadow,
/// and optional default text that behaves like a prompt until the user types.
public final class RoundedTextField: UITextField {
    /// Text shown before the user types. It clears on first edit and reappears when left empty.
    var promptText: String = "Type here..." {
        didSet {
            if showsPromptText {
                applyPromptText()
            }
        }
    }

    private var showsPromptText = false
    private var originalText: String?
    
    public init(originalText: String) {
        self.originalText = originalText
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    private func commonInit() {
        borderStyle = .none
        backgroundColor = .systemBackground
        textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        tintColor = .systemBlue
        autocorrectionType = .no
        font = .systemFont(ofSize: 14, weight: .semibold)

        layer.cornerRadius = 16
        layer.borderWidth = 0.3
        layer.borderColor = UIColor.systemGray4.cgColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 3)

        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)

        // Use the provided original text as the prompt if available
        if let originalText, !originalText.isEmpty {
            promptText = originalText
        }

        applyPromptText()
    }

    @objc private func editingDidBegin() {
        guard showsPromptText else { return }
        text = nil
        textColor = .label
        showsPromptText = false
    }

    @objc private func editingDidEnd() {
        guard let current = text?.trimmingCharacters(in: .whitespacesAndNewlines), current.isEmpty else {
            return
        }
        applyPromptText()
    }

    private func applyPromptText() {
        text = promptText
        textColor = .secondaryLabel
        showsPromptText = true
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 14, dy: 10)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 14, dy: 10)
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 56)
    }
}

