import UIKit

/// A reusable text field with rounded corners, drop shadow,
/// and optional default text that behaves like a prompt until the user types.
public final class RoundedTextField: UITextField {
    /// Text shown before the user types. It clears on first edit and reappears when left empty.
    var promptText: String = "Type here..." {
        didSet {
            viewModel.promptText = promptText
            applyDisplayState()
        }
    }

    private var originalText: String?
    private let viewModel: RoundedTextFieldViewModel
    private let promptTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    private let inputTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    private let horizontalContentInset: CGFloat = 24
    private var isApplyingProgrammaticTextUpdate = false
    var onRawTextChanged: ((String) -> Void)?
    private lazy var visibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.addTarget(self, action: #selector(toggleTextVisibility), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 21.27, height: 17)
        return button
    }()
    
    public init(
        originalText: String,
        isSecuredTextField: Bool = false,
        isEmailField: Bool = false,
        isPasswordField: Bool = false
    ) {
        self.originalText = originalText
        self.viewModel = RoundedTextFieldViewModel(
            promptText: originalText,
            isSecuredTextField: isSecuredTextField,
            isEmailField: isEmailField,
            isPasswordField: isPasswordField
        )
        super.init(frame: .zero)
        promptText = originalText
        commonInit()
    }

    override init(frame: CGRect) {
        self.viewModel = RoundedTextFieldViewModel(
            promptText: "Type here...",
            isSecuredTextField: false,
            isEmailField: false,
            isPasswordField: false
        )
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.viewModel = RoundedTextFieldViewModel(
            promptText: "Type here...",
            isSecuredTextField: false,
            isEmailField: false,
            isPasswordField: false
        )
        super.init(coder: coder)
        commonInit()
    }

    var rawText: String {
        viewModel.rawText
    }

    var isValidEmail: Bool {
        viewModel.isValidEmail
    }

    @discardableResult
    func validateEmailIfNeeded() -> Bool {
        viewModel.validateEmailIfNeeded()
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
        autocapitalizationType = .none
        font = UIFont(name: "SFProText-Semibold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)

        if viewModel.isEmailField {
            keyboardType = .emailAddress
            textContentType = .emailAddress
        }

        if viewModel.isPasswordField {
            textContentType = .newPassword
        }

        layer.cornerRadius = 16
        layer.borderWidth = 0.3
        layer.borderColor = UIColor.systemGray4.cgColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)

        if viewModel.isSecuredTextField {
            configureSecureToggle()
        }

        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)

        // Use the provided original text as the prompt if available
        if let originalText, !originalText.isEmpty {
            promptText = originalText
        }

        applyDisplayState()
    }

    @objc private func editingDidBegin() {
        viewModel.beginEditing()
        applyDisplayState()
        onRawTextChanged?(viewModel.rawText)
    }

    @objc private func editingDidEnd() {
        viewModel.endEditing()
        applyDisplayState()
        onRawTextChanged?(viewModel.rawText)
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
        applyDisplayState()
    }

    private func updateVisibilityIcon() {
        let imageName = viewModel.isTextHidden ? "eye.slash" : "eye"
        visibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
        visibilityButton.accessibilityLabel = viewModel.isTextHidden ? "Show password" : "Hide password"
    }

    @objc private func toggleTextVisibility() {
        guard viewModel.isSecuredTextField else { return }
        viewModel.toggleVisibility()
        updateVisibilityIcon()
        applyDisplayState()
        onRawTextChanged?(viewModel.rawText)
    }

    @objc private func editingChanged() {
        guard !isApplyingProgrammaticTextUpdate else { return }
        viewModel.updateFromEditing(displayedValue: text ?? "")
        applyDisplayState()
        onRawTextChanged?(viewModel.rawText)
    }

    private func applyDisplayState() {
        isApplyingProgrammaticTextUpdate = true
        super.text = viewModel.displayedText
        textColor = viewModel.showsPromptText ? promptTextColor : inputTextColor
        isApplyingProgrammaticTextUpdate = false
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

