import UIKit
import SnapKit
import ShadowImageButton
import Utilities

class ImportInfoCell: UITableViewCell {
    static let reuseID = "ImportInfoCell"
    
    private let containerView: UIImageView = {
        let view = UIImageView(image: .init(named: "settingsPremiumBackground"))
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
    }()
    
    private let leftImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "importInfo"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let infoTitle: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 20)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Ready to print".localized
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let infoSubtitle: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 16)
        label.textAlignment = .left
        label.textColor = .init(hex: "B6E0F3")
        label.text = "Upload files from gallery, scanner or browser".localized
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(infoTitle, infoSubtitle, leftImageView)
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(17)
        }
        
        infoTitle.snp.makeConstraints {
            $0.left.equalToSuperview().inset(139)
            $0.trailing.equalToSuperview().inset(5)
            $0.top.equalToSuperview().inset(30)
        }
        
        infoSubtitle.snp.makeConstraints {
            $0.leading.equalTo(infoTitle)
            $0.trailing.equalTo(infoTitle)
            $0.top.equalTo(infoTitle.snp.bottom).offset(4)
        }
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(5)
            make.top.equalToSuperview()
            make.height.equalTo(148)
            make.width.equalTo(133)
        }
    }
}
