import UIKit
import WebKit
import SnapKit
import SafariServices
import PremiumManager
import Combine
import RxSwift
import Utilities
import CustomBlurEffectView

final class AppSettingsViewController: BaseController {

    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let settingsModel = SettingsModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsModel.refresh()
    }

    private func setupUI() {
        setupNavigationBar()
        setupTableView()
    }

    private func setupNavigationBar() {
        titleLabel.text = "Settings".localized
        titleLabel.font = .font(weight: .bold, size: 22)
        configurNavigation(leftView: titleLabel)
    }

    private func setupTableView() {
        tableView.register(PremiumPromotionCell.self, forCellReuseIdentifier: PremiumPromotionCell.identifier)
        tableView.register(BaseCell.self, forCellReuseIdentifier: BaseCell.reuseID)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = .init(top: 20, left: 0, bottom: 100, right: 0)

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(63)
            $0.left.right.bottom.equalToSuperview()
        }
    }

    private func observeModel() {
        settingsModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension AppSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = settingsModel.items[indexPath.row]
        switch row {
        case .promo:
            let cell = tableView.dequeueReusableCell(withIdentifier: PremiumPromotionCell.identifier, for: indexPath) as! PremiumPromotionCell
            return cell
        case .option(let item):
            let cell = tableView.dequeueReusableCell(withIdentifier: BaseCell.reuseID, for: indexPath) as! BaseCell
            cell.configure(type: item)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = settingsModel.items[indexPath.row]
        switch row {
        case .promo:
            PaywallManager.shared.showPaywall()
        case .option(let option):
            handle(option: option)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch settingsModel.items[indexPath.row] {
        case .promo: return 160
        case .option: return 76
        }
    }

    private func handle(option: SettingsOption) {
        switch option {
        case .privacyPolicy:
            openWebView(Config.privacy)
        case .termsOfService:
            openWebView(Config.terms)
        case .alternateIcons:
            presentCrossDissolve(vc: IconsController())
        case .clearCache:
            clearWebCache(presenting: self)
        case .share:
            let shareURL = URL(string: "https://apps.apple.com/us/app/\(Config.appId)")!
            let vc = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            present(vc, animated: true)
        }
    }
    
    func clearWebCache(presenting viewController: UIViewController) {
        let dataStore = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()

        dataStore.fetchDataRecords(ofTypes: types) { records in
            dataStore.removeData(ofTypes: types, for: records) {

                let alert = UIAlertController(
                    title: "Cache Cleared".localized,
                    message: "Website cache and cookies have been successfully removed.".localized,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                DispatchQueue.main.async {
                    viewController.present(alert, animated: true)
                }
            }
        }
    }

    private func openWebView(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
}

final class SettingsModel {
    private let bag = DisposeBag()
    var onUpdate: (() -> Void)?

    private(set) var items: [SettingsItem] = []

    init() {
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isPremium in
                self?.generateItems(isPremium: isPremium)
            }).disposed(by: bag)
    }

    func refresh() {
        generateItems(isPremium: PremiumManager.shared.isPremium.value)
    }

    private func generateItems(isPremium: Bool) {
        items = []
        if !isPremium {
            items.append(.promo)
        }
        items += [
            .option(.clearCache),
            .option(.share),
            .option(.alternateIcons),
            .option(.privacyPolicy),
            .option(.termsOfService)
        ]
        onUpdate?()
    }
}


protocol SettingsOptionRepresentable {
    var iconAsset: UIImage? { get }
    var displayTitle: String { get }
}

enum SettingsOption: SettingsOptionRepresentable {
    case clearCache
    case privacyPolicy
    case termsOfService
    case alternateIcons
    case share
    
    var iconAsset: UIImage? {
        switch self {
        case .clearCache: return UIImage(named: "clearCache")
        case .privacyPolicy: return UIImage(named: "privacy")
        case .termsOfService: return UIImage(named: "terms")
        case .alternateIcons: return UIImage(named: "switchIcon")
        case .share: return UIImage(named: "share")
        }
    }
    
    var displayTitle: String {
        switch self {
        case .clearCache: return "Clear cache".localized
        case .privacyPolicy: return "Privacy Policy".localized
        case .termsOfService: return "Terms of Use".localized
        case .alternateIcons: return "Change icon".localized
        case .share: return "Share app".localized
        }
    }
}

enum SettingsRowConfiguration {
    case premiumPromotion
    case standardOption(SettingsOption)
}

enum SettingsItem {
    case promo
    case option(SettingsOption)
}

final class PremiumPromotionCell: UITableViewCell {
    static let identifier = "PremiumPromotionCell"
    
    private lazy var customBackgroundView: UIView  = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    private let backgroundImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "settingsPremiumBackground"))
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    private let imageViewLeft = UIImageView(image: UIImage(named: "settingsPremium"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let button = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        titleLabel.text = "Get Premium".localized
        titleLabel.textColor = .white
        titleLabel.font = .font(weight: .heavy, size: 22)
        titleLabel.numberOfLines = 2

        subtitleLabel.text = "Make the most of your time with phone".localized
        subtitleLabel.textColor = .init(hex: "C4E4FE")
        subtitleLabel.font = .font(weight: .semibold, size: 14)
        subtitleLabel.numberOfLines = 2

        button.setTitle("Try now".localized, for: .normal)
        button.titleLabel?.font = .font(weight: .bold, size: 15)
        button.setTitleColor(.init(hex: "303030"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.isUserInteractionEnabled = false
        button.applyDropShadow(color: .init(hex: "10008D"), opacity: 0.2, offset: .init(width: 0, height: 4), radius: 21)
        
        customBackgroundView.applyDropShadow(color: .init(hex: "2583FF"), opacity: 0.53, offset: .init(width: 0, height: 4), radius: 12)
        
        contentView.addSubview(customBackgroundView)
        
        customBackgroundView.addSubview(backgroundImageView)
        
        backgroundImageView.addSubviews(imageViewLeft, titleLabel, subtitleLabel, button)

        customBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 25, bottom: 18, right: 25))
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageViewLeft.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18)
            $0.leading.equalTo(button)
            $0.width.equalTo(200)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(button)
            $0.width.equalTo(200)
        }

        button.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 120, height: 32))
            $0.bottom.equalToSuperview().inset(11)
            $0.leading.equalToSuperview().inset(159)
        }
    }
}
