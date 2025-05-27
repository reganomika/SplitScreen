import UIKit
import PremiumManager
import StoreKit
import SafariServices
import SnapKit
import RxSwift
import ShadowImageButton
import Utilities
import ApphudSDK

class PaywallController: OnboardingController {

    private let premiumManager = PremiumManager.shared

    private lazy var topProduct = premiumManager.products.value.first(where: { $0.skProduct?.introductoryPrice == nil })
    private lazy var bottomProduct = premiumManager.products.value.first(where: { $0.skProduct?.introductoryPrice != nil })
    
    public var customTitle: String = "" {
        didSet {
            updateTitle()
        }
    }
    
    public var customSubtitle: String = "" {
        didSet {
            subtitleLabel.attributedText = customSubtitle.attributedString(
                font: .font(weight: .medium, size: 18),
                aligment: .center,
                color: .init(hex: "A3A3B9"),
                lineSpacing: 0,
                maxHeight: 20
            )
        }
    }

    var productToPurchase: ApphudProduct?

    private lazy var topOptionView: PaywallOptionView = {
        let view = PaywallOptionView()

        let title = topProduct?.duration?.longDescription.lowercased().localized.capitalized ?? "-"
        var rightTitle = "-"
        var subtitle: String?

        if let product = topProduct,
           let duration = product.duration,
           let price = product.priceNumber {
            
            let symbol = product.currency

            let days: Double = {
                switch duration {
                case .week: return 7
                case .month: return 30
                case .year: return 365
                case .quarter: return 90
                default: return 1
                }
            }()

            
            rightTitle = "\(symbol)\(String(format: "%.2f", (price / days) * 7))" + "/" + "week".localized.lowercased()
 
        }

        view.configure(
            title: title,
            subtitle: subtitle,
            rightTitle: rightTitle,
            isSelected: false,
            isGradientLabel: topProduct?.trialPeriodDays != nil
        )
        view.add(target: self, action: #selector(topOptionTapped))
        return view
    }()

    private lazy var bottomOptionView: PaywallOptionView = {
        let view = PaywallOptionView()

        let title = bottomProduct?.duration?.longDescription.lowercased().localized.capitalized ?? "-"
        var rightTitle = "-"
        var subtitle: String?

        if let product = bottomProduct,
           let duration = product.duration,
           let price = product.priceNumber {
            
            let symbol = product.currency
            
            let days: Double = {
                switch duration {
                case .week: return 7
                case .month: return 30
                case .year: return 365
                case .quarter: return 90
                default: return 1
                }
            }()
            
            if let trialPeriodDays = product.trialPeriodDays, trialPeriodDays > 0 {
                subtitle = "\(trialPeriodDays)-" + "Day free trial".localized
                rightTitle = "\(symbol)\(String(format: "%.2f", price))/\(duration.rawValue.localized)"
            } else {
                rightTitle = "\(symbol)\(String(format: "%.2f", (price / days) * 7))" + "/" + "week".localized.lowercased()
            }
        }

        view.configure(
            title: title,
            subtitle: subtitle,
            rightTitle: rightTitle,
            isSelected: true,
            isGradientLabel: bottomProduct?.trialPeriodDays != nil
        )
        view.add(target: self, action: #selector(bottomOptionTapped))
        return view
    }()

    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topOptionView, bottomOptionView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var switchView: UISwitch = {
        let view = UISwitch()
        view.isOn = false
        view.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return view
    }()

    private let switchLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 15)
        label.textColor = .init(hex: "303030")
        label.text = "Not sure? Enable free trial".localized
        return label
    }()

    private lazy var switchStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [switchLabel, switchView])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()

    private let highlightedText: String = "Premium".localized
    private let isFromOnboarding: Bool

    private lazy var product: ApphudProduct? = topProduct

    // MARK: - Init

    init(isFromOnboarding: Bool) {
        self.isFromOnboarding = isFromOnboarding
        super.init(
            model: OnboardingModel(image: UIImage(), title: "", higlitedTexts: [], subtitle: "", rating: false),
            coordinator: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        customTitle = "Split Screen Premium".localized
        customSubtitle = "Take all from your device, saving favorite pages in second".localized

        imageView.image = UIImage(named: UIScreen.isBigDevice ? "paywallBig" : "paywall")

        productToPurchase = topProduct
        topOptionView.isSelectedOption = true
        bottomOptionView.isSelectedOption = false
        switchView.isOn = false

        view.addSubview(switchStackView)
        view.addSubview(optionsStackView)

        switchStackView.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).inset(-16)
            $0.height.equalTo(31)
            $0.left.right.equalToSuperview().inset(26)
        }

        optionsStackView.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).inset(-63)
            $0.left.right.equalToSuperview().inset(26)
            $0.height.equalTo(150)
        }

        topOptionView.snp.makeConstraints { $0.height.equalTo(69); $0.left.right.equalToSuperview() }
        bottomOptionView.snp.makeConstraints { $0.height.equalTo(69); $0.left.right.equalToSuperview() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.isBigDevice {
//            imageView.contentMode = .scaleAspectFit
            
            imageView.snp.remakeConstraints {
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(nextButton.snp.top).inset(-215)
            }
        } else {
            imageView.snp.updateConstraints {
                $0.bottom.equalTo(nextButton.snp.top).inset(-209)
            }
        }
 
       
    }

    override func setupButtons() {
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 16

        let notNowButton = createBottomButton(title: "Not now".localized)
        let privacyButton = createBottomButton(title: "Privacy".localized)
        let restoreButton = createBottomButton(title: "Restore".localized)
        let termsButton = createBottomButton(title: "Terms".localized)

        notNowButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)

        bottomStackView.addArrangedSubview(privacyButton)
        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(termsButton)
        bottomStackView.addArrangedSubview(notNowButton)

        view.addSubview(bottomStackView)

        bottomStackView.snp.remakeConstraints {
            $0.top.equalTo(nextButton.snp.bottom).offset(UIScreen.isLittleDevice ? 10 : 21)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.height.equalTo(18)
        }
    }
    
    private func updateTitle() {
        let attributedString = NSMutableAttributedString(attributedString: customTitle.attributedString(
            font: .font(weight: .heavy, size: 29),
            aligment: .center,
            color: .init(hex: "303030"),
            lineSpacing: 5,
            maxHeight: 50
        ))
        
        if !highlightedText.isEmpty {
            let range = (customTitle as NSString).range(of: highlightedText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.init(hex: "227CFA"), range: range)
        }
        
        titleLabel.attributedText = attributedString
    }

    @objc override func closeAction() {
        if isFromOnboarding {
            replaceRootViewController(with: TabBarController())
        } else {
            dismiss()
        }
    }

    override func nexAction() {
        premiumManager.purchase(product: productToPurchase)
    }

    // MARK: - Actions

    @objc func switchChanged(_ sender: UISwitch) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if sender.isOn {
            bottomOptionTapped()
        } else {
            topOptionTapped()
        }
    }

    @objc func topOptionTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        productToPurchase = topProduct
        topOptionView.isSelectedOption = true
        bottomOptionView.isSelectedOption = false
        switchView.isOn = false
        
        nextButton.updateTitle(title: "Continue".localized)
    }

    @objc func bottomOptionTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        productToPurchase = bottomProduct
        topOptionView.isSelectedOption = false
        bottomOptionView.isSelectedOption = true
        switchView.isOn = true
        nextButton.updateTitle(title: "Try for free".localized)
    }
}
