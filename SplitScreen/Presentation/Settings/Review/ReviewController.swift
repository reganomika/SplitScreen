import UIKit
import ShadowImageButton
import SafariServices
import StoreKit
import SnapKit
import CustomBlurEffectView
import Utilities

final class ReviewController: UIViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let blurRadius: CGFloat = 3
        static let blurColor = UIColor(hex: "171313")
        static let blurAlpha: CGFloat = 0.3
        
        static let contentBackground = UIColor.white
        static let contentCornerRadius: CGFloat = 28
        static let contentHeight: CGFloat = 413
        
        static let titleFontSize: CGFloat = 24
        static let subtitleFontSize: CGFloat = 18
        static let buttonFontSize: CGFloat = 16
        
        static let subtitleColor = UIColor(hex: "B2B2B2")
        static let closeButtonAlpha: CGFloat = 0.44
        
        static let horizontalInset: CGFloat = 24
        static let wideHorizontalInset: CGFloat = 24
        static let extraWideInset: CGFloat = 24
        
        static let buttonHeight: CGFloat = 69
        static let closeButtonHeight: CGFloat = 21
        static let buttonCornerRadius: CGFloat = 18
        static let buttonBorderWidth: CGFloat = 6
        
        static let imageTopInset: CGFloat = 0
        static let titleBottomOffset: CGFloat = 17
        static let subtitleBottomOffset: CGFloat = 31
        static let buttonBottomOffset: CGFloat = 11
        static let closeButtonBottomInset: CGFloat = 22
        
        static let shadowRadius: CGFloat = 14.7
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let shadowOpacity: Float = 0.5
    }
    
    private enum Strings {
        static let title = "Would you recommend us?".localized
        static let subtitle = "Tell us your thoughts – help us improve your experience".localized
        static let buttonTitle = "Share feedback".localized
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
            color: .init(hex: "303030"),
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
                image: UIImage(named: "buttonBackground"),
                cornerRadius: Constants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "2583FF"),
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            $0.height.equalTo(209)
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.buttonBottomOffset)
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
        let appId = Config.appId
        let urlString = "https://itunes.apple.com/app/id\(appId)?action=write-review"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for feedback form")
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .formSheet
        
        if let topController = UIApplication.topViewController(){
            topController.present(safariVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
