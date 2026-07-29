import UIKit

/// A reusable text field with rounded corners, drop shadow,
/// and optional default text that behaves like a prompt until the user types.

// TODO: Drop comments + improve the shadow and impl. the hide/show feature
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
    private let isSecuredTextField: Bool
    private var isTextHidden = true
    private var secureRawText = ""
    private var isApplyingSecureTextUpdate = false
    private let promptTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    private let inputTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    private let horizontalContentInset: CGFloat = 24
    private lazy var visibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.addTarget(self, action: #selector(toggleTextVisibility), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 21.27, height: 17)
        return button
    }()
    
    public init(originalText: String, isSecuredTextField: Bool = false) {
        self.originalText = originalText
        self.isSecuredTextField = isSecuredTextField
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) { // TODO: Review if i really need both inits with coder and frame?
        self.isSecuredTextField = false
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.isSecuredTextField = false
        super.init(coder: coder)
        commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let bottomShadowHeight: CGFloat = 14
        let bottomShadowRect = CGRect(
            x: 0,
            y: bounds.height - bottomShadowHeight,
            width: bounds.width,
            height: bottomShadowHeight
        )
        layer.shadowPath = UIBezierPath(
            roundedRect: bottomShadowRect,
            cornerRadius: layer.cornerRadius
        ).cgPath
    }

    private func commonInit() {
        borderStyle = .none
        backgroundColor = .systemBackground
        textColor = promptTextColor
        tintColor = .systemBlue
        autocorrectionType = .no
        font = UIFont(name: "SFProText-Semibold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)

        layer.cornerRadius = 16
        layer.borderWidth = 0.3
        layer.borderColor = UIColor.systemGray4.cgColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)

        if isSecuredTextField {
            configureSecureToggle()
        }

        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)

        // Use the provided original text as the prompt if available
        if let originalText, !originalText.isEmpty {
            promptText = originalText
        }

        applyPromptText()
    }

    @objc private func editingDidBegin() {
        if showsPromptText {
            text = nil
            textColor = inputTextColor
            showsPromptText = false
        }

        if isSecuredTextField {
            applySecureDisplayText()
        }
    }

    @objc private func editingDidEnd() {
        guard let current = text?.trimmingCharacters(in: .whitespacesAndNewlines), current.isEmpty else {
            return
        }
        applyPromptText()
    }

    private func applyPromptText() {
        text = promptText
        textColor = promptTextColor
        showsPromptText = true
        secureRawText = ""
    }

    private func configureSecureToggle() {
        let trailingPadding: CGFloat = 20
        let containerHeight = max(visibilityButton.frame.height, 28)
        let containerWidth = visibilityButton.frame.width + trailingPadding
        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))

        visibilityButton.frame.origin = CGPoint(
            x: 0,
            y: (containerHeight - visibilityButton.frame.height) / 2
        )
        rightContainer.addSubview(visibilityButton)

        rightView = rightContainer
        rightViewMode = .always
        updateVisibilityIcon()
        applySecureDisplayText()
    }

    private func updateVisibilityIcon() {
        let imageName = isTextHidden ? "eye.slash" : "eye"
        visibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
        visibilityButton.accessibilityLabel = isTextHidden ? "Show password" : "Hide password"
    }

    @objc private func toggleTextVisibility() {
        guard isSecuredTextField else { return }

        isTextHidden.toggle()
        updateVisibilityIcon()
        applySecureDisplayText()
    }

    @objc private func editingChanged() {
        guard isSecuredTextField, !showsPromptText, !isApplyingSecureTextUpdate else { return }
        textColor = inputTextColor

        if isTextHidden {
            let editedText = text ?? ""
            let previousMaskedText = String(repeating: "*", count: secureRawText.count)

            if editedText.count > previousMaskedText.count {
                let appended = String(editedText.dropFirst(previousMaskedText.count))
                secureRawText += appended
            } else if editedText.count < previousMaskedText.count {
                secureRawText = String(secureRawText.prefix(editedText.count))
            }

            applySecureDisplayText()
        } else {
            secureRawText = text ?? ""
        }
    }

    private func applySecureDisplayText() {
        guard isSecuredTextField, !showsPromptText else { return }

        isApplyingSecureTextUpdate = true
        textColor = inputTextColor
        super.text = isTextHidden ? String(repeating: "*", count: secureRawText.count) : secureRawText
        isApplyingSecureTextUpdate = false
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let baseRect = super.textRect(forBounds: bounds)
        return baseRect.insetBy(dx: horizontalContentInset, dy: 0)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let baseRect = super.editingRect(forBounds: bounds)
        return baseRect.insetBy(dx: horizontalContentInset, dy: 0)
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 49)
    }
}

