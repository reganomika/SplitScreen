import UIKit
import SnapKit
import Utilities

final class PaywallOptionView: UIView {
    
    var isSelectedOption: Bool = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateAppearance()
            }
        }
    }
    
    lazy var backgroundimageView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 18)
        label.textColor = .init(hex: "303030")
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .init(hex: "227CFA")
        label.font = .font(weight: .semibold, size: 14)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        return label
    }()
    
    lazy var rightTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .init(hex: "303030")
        label.font = .font(weight: .semibold, size: 16)
        label.textAlignment = .right
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackView, rightTitleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        title: String,
        subtitle: String?,
        rightTitle: String,
        isSelected: Bool,
        isGradientLabel: Bool
    ) {
        titleLabel.text = title
        
        
        rightTitleLabel.text = rightTitle
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        isSelectedOption = isSelected
    }
    
    func setupUI() {
        addSubviews(backgroundimageView, horizontalStackView)
        
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        clipsToBounds = true
        
    }
    
    func setupConstraints() {
        
        backgroundimageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        horizontalStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func updateAppearance() {
        
        if isSelectedOption {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            applyGradientBorder(
                colors: [UIColor(hex: "#38C2FE"), UIColor(hex: "#325FFA")],
                lineWidth: 6, cornerRadius: 20
            )
        } else {
            layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
            layer.borderWidth = 1
            layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }
}
