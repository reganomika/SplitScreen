import UIKit
import ShadowImageButton
import SafariServices
import StoreKit
import SnapKit
import CustomBlurEffectView
import Utilities

final class ReviewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let blurRadius: CGFloat = 3
        static let blurColor = UIColor(hex: "171313")
        static let blurAlpha: CGFloat = 0.3
        
        static let contentBackground = UIColor(hex: "0F1C35")
        static let contentCornerRadius: CGFloat = 30
        static let contentHeight: CGFloat = 547
        
        static let titleFontSize: CGFloat = 24
        static let subtitleFontSize: CGFloat = 18
        static let buttonFontSize: CGFloat = 16
        
        static let subtitleColor = UIColor(hex: "ADACB8")
        static let closeButtonAlpha: CGFloat = 0.44
        
        static let horizontalInset: CGFloat = 22
        static let wideHorizontalInset: CGFloat = 30
        static let extraWideInset: CGFloat = 39
        
        static let buttonHeight: CGFloat = 69
        static let closeButtonHeight: CGFloat = 21
        static let buttonCornerRadius: CGFloat = 18
        static let buttonBorderWidth: CGFloat = 6
        
        static let imageTopInset: CGFloat = 15
        static let titleBottomOffset: CGFloat = 12
        static let subtitleBottomOffset: CGFloat = 30
        static let buttonBottomOffset: CGFloat = 24
        static let closeButtonBottomInset: CGFloat = 22
        
        static let shadowRadius: CGFloat = 14.7
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let shadowOpacity: Float = 0.5
    }
    
    private enum Strings {
        static let title = "We’d love your feedback!".localized
        static let subtitle = "Tell us what you think about our app — we’re all ears!".localized
        static let buttonTitle = "Write a feedback".localized
    }
    
    // MARK: - UI Components
    
    private let blurView = CustomBlurEffectView().apply {
        $0.blurRadius = Constants.blurRadius
        $0.colorTint = Constants.blurColor
        $0.colorTintAlpha = Constants.blurAlpha
    }
    
    private let contentView = UIView().apply {
        $0.backgroundColor = Constants.contentBackground
        $0.layer.cornerRadius = Constants.contentCornerRadius
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let imageView = UIImageView().apply {
        $0.image = UIImage(named: "review")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    private let titleLabel = UILabel().apply {
        $0.attributedText = Strings.title.localized.attributedString(
            font: .font(weight: .bold, size: Constants.titleFontSize),
            aligment: .center,
            color: UIColor.white,
            lineSpacing: 5,
            maxHeight: 50
        )
        
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private let subtitleLabel = UILabel().apply {
        $0.text = Strings.subtitle
        $0.font = .font(weight: .medium, size: Constants.subtitleFontSize)
        $0.textColor = Constants.subtitleColor
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private lazy var feedbackButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: Strings.buttonTitle,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "settingsPremiumBackground"),
                cornerRadius: Constants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "0044FF"),
                    opacity: Constants.shadowOpacity,
                    offset: Constants.shadowOffset,
                    radius: Constants.shadowRadius
                )
            )
        )
        $0.action = { [weak self] in self?.feedbackTapped() }
    }
    
    private lazy var closeButton = UIButton().apply {
        $0.setImage(UIImage(named: "close"), for: .normal)
        $0.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        setupConstraints()
        markFeedbackAsShown()
    }
    
    // MARK: - Setup
    
    private func configureViewHierarchy() {
        view.addSubviews(blurView)
        blurView.addSubviews(contentView)
        contentView.addSubviews(
            imageView,
            titleLabel,
            subtitleLabel,
            feedbackButton,
            closeButton
        )
    }
    
    private func setupConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(Constants.contentHeight)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Constants.imageTopInset)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).inset(Constants.imageTopInset)
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-Constants.titleBottomOffset)
            $0.leading.trailing.equalToSuperview().inset(Constants.horizontalInset)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(feedbackButton.snp.top).offset(-adjustedBottomOffset())
            $0.leading.trailing.equalToSuperview().inset(Constants.extraWideInset)
        }
        
        feedbackButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.wideHorizontalInset)
            $0.height.equalTo(Constants.buttonHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(39)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(23.0)
            $0.height.width.equalTo(31)
            $0.trailing.equalToSuperview().inset(28.0)
        }
    }
    
    // MARK: - Helpers
    
    private func markFeedbackAsShown() {
        Storage.shared.wasReviewScreen = true
    }
    
    private func adjustedBottomOffset() -> CGFloat {
        UIScreen.isLittleDevice ? Constants.subtitleBottomOffset : Constants.subtitleBottomOffset + 10
    }
    
    private func adjustedCloseButtonInset() -> CGFloat {
        UIScreen.isLittleDevice ? Constants.closeButtonBottomInset : Constants.closeButtonBottomInset + 30
    }
    
    // MARK: - Actions
    
    @objc private func close() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss(animated: true)
    }
    
    @objc private func feedbackTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presentFeedbackForm()
    }
    
    private func presentFeedbackForm() {
        guard let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(Config.appId)?action=write-review") else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
}
