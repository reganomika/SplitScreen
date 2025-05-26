import UIKit
import SnapKit

protocol AddressBarViewDelegate: AnyObject {
    func addressBarDidTapBack()
    func addressBarDidTapReload()
    func addressBarDidTapFavorite()
    func addressBarDidTapShare()
    func addressBarDidTapClear()
    func addressBarTextDidChange(_ text: String)
    func addressBarDidSubmitSearch(_ query: String)
}

final class AddressBarView: UIView, UITextFieldDelegate {
    
    weak var delegate: AddressBarViewDelegate?

    private let backgroundContainer = UIView()
    private let backButton = UIButton()
    private let reloadButton = UIButton()
    private let favoriteButton = UIButton()
    private let rightActionButton = UIButton()
    private let textField = UITextField()

    private var isEditingText: Bool = false {
        didSet {
            updateRightButton()
        }
    }

    var isWebVisible: Bool = true {
        didSet {
            let alpha: CGFloat = isWebVisible ? 1 : 0.4
            [backButton, reloadButton, favoriteButton].forEach {
                $0.isUserInteractionEnabled = isWebVisible
                $0.alpha = alpha
            }

            let isRightEnabled = isWebVisible || isEditingText
            rightActionButton.isUserInteractionEnabled = isRightEnabled
        }
    }

    var isFavorite: Bool = false {
        didSet {
            let image = UIImage(named: isFavorite ? "favFilled" : "favUnfilled")
            favoriteButton.setImage(image, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateRightButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(backgroundContainer)
        addSubview(rightActionButton)

        backgroundContainer.backgroundColor = .white
        backgroundContainer.layer.cornerRadius = 13
        backgroundContainer.layer.masksToBounds = true

        configureButton(backButton, imageName: "back", action: #selector(backTapped))
        configureButton(reloadButton, imageName: "reload", action: #selector(reloadTapped))
        configureButton(favoriteButton, imageName: "favUnfilled", action: #selector(favoriteTapped))
        configureButton(rightActionButton, imageName: "share", action: #selector(rightTapped))
        
        rightActionButton.backgroundColor = .white
        rightActionButton.layer.cornerRadius = 13
        rightActionButton.layer.masksToBounds = true

        textField.font = .font(weight: .medium, size: 16)
        textField.textColor = .init(hex: "303030")
        textField.placeholder = "Search".localized
        textField.borderStyle = .none
        textField.delegate = self
        textField.returnKeyType = .go
        textField.clearButtonMode = .never

        backgroundContainer.addSubviews(backButton, reloadButton, favoriteButton, textField)
        layoutUI()
    }

    private func layoutUI() {
        rightActionButton.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(46)
        }

        backgroundContainer.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(rightActionButton.snp.left).offset(-6)
            $0.top.bottom.equalToSuperview()
        }

        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }

        reloadButton.snp.makeConstraints {
            $0.right.equalTo(favoriteButton.snp.left).offset(-6)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }

        favoriteButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }

        textField.snp.makeConstraints {
            $0.left.equalTo(backButton.snp.right).offset(8)
            $0.right.equalTo(reloadButton.snp.left).offset(-8)
            $0.top.bottom.equalToSuperview().inset(12)
        }
    }

    private func configureButton(_ button: UIButton, imageName: String, action: Selector) {
        let image = UIImage(named: imageName)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func updateRightButton() {
        let image = isEditingText
        ? UIImage(named: "closeWeb")
        : UIImage(named: "shareWeb")
        rightActionButton.setImage(image, for: .normal)
    }

    // MARK: - External API

    func setText(_ text: String) {
        textField.text = text
        isEditingText = !text.isEmpty
    }

    // MARK: - Actions

    @objc private func backTapped() {
        delegate?.addressBarDidTapBack()
    }

    @objc private func reloadTapped() {
        delegate?.addressBarDidTapReload()
    }

    @objc private func favoriteTapped() {
        delegate?.addressBarDidTapFavorite()
    }

    @objc private func rightTapped() {
        isEditingText
            ? delegate?.addressBarDidTapClear()
            : delegate?.addressBarDidTapShare()
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidChangeSelection(_ textField: UITextField) {
        isEditingText = !(textField.text?.isEmpty ?? true)
        delegate?.addressBarTextDidChange(textField.text ?? "")
        
        let isRightEnabled = isWebVisible || isEditingText
        rightActionButton.isUserInteractionEnabled = isRightEnabled
        rightActionButton.alpha = isRightEnabled ? 1 : 0.4
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.addressBarDidSubmitSearch(textField.text ?? "")

        isEditingText = false
        updateRightButton()
        
        let isRightEnabled = isWebVisible || isEditingText
        rightActionButton.isUserInteractionEnabled = isRightEnabled
        rightActionButton.alpha = isRightEnabled ? 1 : 0.4

        return true
    }
}
