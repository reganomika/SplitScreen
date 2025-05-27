import UIKit
import PremiumManager
import StoreKit
import SafariServices
import SnapKit
import RxSwift
import ShadowImageButton
import Utilities

private enum Constants {
    static let buttonHeight: CGFloat = UIScreen.isBigDevice ? 80 : 69
    static let buttonCornerRadius: CGFloat = 18
    static let shadowRadius: CGFloat = 9
    static let shadowOffset = CGSize(width: 0, height: 8)
    static let shadowOpacity: Float = 0.53
}

class OnboardingController: BaseController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let bottomStackView = UIStackView()
    
    let disposeBag = DisposeBag()
    
    lazy var nextButton: ShadowImageButton = {
        let button = ShadowImageButton()
        button.configure(
            buttonConfig: .init(
                title: "Continue".localized,
                font: .font(
                    weight: .bold,
                    size: UIScreen.isBigDevice ? 20 : 18
                ),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "settingsPremiumBackground"),
                cornerRadius: Constants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "#2583FF"),
                    opacity: Constants.shadowOpacity,
                    offset: Constants.shadowOffset,
                    radius: Constants.shadowRadius
                )
            )
        )
        button.backgroundColor = .init(hex: "0055F1")
        button.add(target: self, action: #selector(nextButtonTapped))
        return button
    }()
    
    weak var coordinator: OnboardingCoordinator?
    let model: OnboardingModel
    
    init(model: OnboardingModel, coordinator: OnboardingCoordinator?) {
        self.model = model
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupButtons()
        
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .subscribe(onNext: { [weak self] isPremium in
                if isPremium {
                    self?.close()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func setupView() {
        super.setupView()
        
        imageView.image = model.image
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        titleLabel.numberOfLines = 0
        
        let attributedString = NSMutableAttributedString(attributedString: model.title.attributedString(
            font: .font(weight: .heavy, size: 32),
            aligment: .center,
            color: .init(hex: "303030"),
            lineSpacing: 5,
            maxHeight: 50
        ))
        
        for higlitedText in model.higlitedTexts {
            let range = (model.title as NSString).range(of: higlitedText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.init(hex: "227CFA"), range: range)
            
            titleLabel.attributedText = attributedString
        }

        view.addSubview(titleLabel)
        
        subtitleLabel.numberOfLines = 0
        
        subtitleLabel.attributedText = model.subtitle.attributedString(
            font: .font(weight: .medium, size: 18),
            aligment: .center,
            color: .init(hex: "A3A3B9"),
            lineSpacing: 0,
            maxHeight: 20
        )
        view.addSubview(subtitleLabel)
        
        view.addSubview(nextButton)
    }
    
    func setupButtons() {
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 16
        
        let privacyButton = createBottomButton(title: "Privacy".localized)
        let restoreButton = createBottomButton(title: "Restore".localized)
        let termsButton = createBottomButton(title: "Terms".localized)
        
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        bottomStackView.addArrangedSubview(privacyButton)
        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(termsButton)
        
        view.addSubview(bottomStackView)
        
        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(UIScreen.isLittleDevice ? 10 : 21)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(18)
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UIScreen.isBigDevice ? 215 : 215)
            make.bottom.equalTo(nextButton.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UIScreen.isBigDevice ? 61 : 61)
            make.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(UIScreen.isLittleDevice ? -20 : -16)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(Constants.buttonHeight)
        }
    }
    
    func createBottomButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.init(hex: "B2B2B2"), for: .normal)
        button.titleLabel?.font = .font(weight: .medium, size: Locale.current.languageCode == "de" ? 10 : 14)
        return button
    }
    
    @objc private func nextButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        nexAction()
    }
    
    func nexAction() {
        if model.rating {
            SKStoreReviewController.requestReview()
        }
        coordinator?.goToNextScreen()
    }
    
    @objc func openPrivacy() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let url = URL(string: Config.privacy) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc func openTerms() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let url = URL(string: Config.terms) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc func restore() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        PremiumManager.shared.restorePurchases()
    }
    
    @objc private func close() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        closeAction()
    }
    
    func closeAction() {
        replaceRootViewController(with: TabBarController())
    }
}
