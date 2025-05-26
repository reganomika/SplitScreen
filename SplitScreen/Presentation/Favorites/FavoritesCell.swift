import UIKit
import SnapKit

final class FavoritesCell: UITableViewCell {
    
    static let identifier = "FavoritesCell"
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton()
    private let separatorView = UIView()
    
    var onActionTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        contentView.addSubview(iconImageView)
        
        titleLabel.font = .font(weight: .semibold, size: 18)
        titleLabel.textColor = .init(hex: "303030")
        contentView.addSubview(titleLabel)
        
        subtitleLabel.font = .font(weight: .regular, size: 16)
        subtitleLabel.textColor = .init(hex: "303030")
        contentView.addSubview(subtitleLabel)
        
        actionButton.setImage(UIImage(named: "dots"), for: .normal)
        actionButton.tintColor = .gray
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        contentView.addSubview(actionButton)
        
        separatorView.backgroundColor = .init(hex: "DBDBF3")
        contentView.addSubview(separatorView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        iconImageView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        
        actionButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.top)
            $0.left.equalTo(iconImageView.snp.right).offset(12)
            $0.right.equalTo(actionButton.snp.left).offset(-8)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(iconImageView.snp.bottom)
            $0.left.equalTo(titleLabel.snp.left)
            $0.right.equalTo(titleLabel.snp.right)
        }
        
        separatorView.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    @objc private func actionTapped() {
        onActionTapped?()
    }
    
    func configure(with model: FavoritePage) {
        titleLabel.text = model.title
        subtitleLabel.text = model.url
        if let image = UIImage(data: model.iconData) {
            iconImageView.image = image
        } else {
            iconImageView.image = UIImage(systemName: "globe")
        }
    }
    
    func configureCorners(at index: Int, rowCount: Int) {
        let topRadius: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let bottomRadius: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        var maskedCorners: CACornerMask = []

        if index == 0 {
            maskedCorners.formUnion(topRadius)
        }
        if index == rowCount - 1 {
            maskedCorners.formUnion(bottomRadius)
        }

        contentView.layer.cornerRadius = maskedCorners.isEmpty ? 0 : 16
        contentView.layer.maskedCorners = maskedCorners

        separatorView.isHidden = index == rowCount - 1
    }
}
