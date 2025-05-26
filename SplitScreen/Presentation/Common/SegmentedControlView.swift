import UIKit
import SnapKit

final class SegmentedControlView: UIView {
    
    private lazy var customBackgroundView: UIView  = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()

    private lazy var selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "buttonBackground")
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("Favorites".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .font(weight: .medium, size: 16)
        button.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("Recent".localized, for: .normal)
        button.setTitleColor(.init(hex: "B2B2B2"), for: .normal)
        button.titleLabel?.font = .font(weight: .medium, size: 16)
        button.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 22
        return view
    }()
    
    private var selectionLeftConstraint: Constraint?
    
    var isLeftSelected = true
    var onLeftSelected: (() -> Void)?
    var onRightSelected: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(customBackgroundView)
        containerView.addSubview(leftButton)
        containerView.addSubview(rightButton)
        
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        leftButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        rightButton.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        customBackgroundView.snp.makeConstraints { make in
            selectionLeftConstraint = make.left.equalToSuperview().offset(8).constraint
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().inset(6)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }
        
        customBackgroundView.addSubview(selectionImageView)
        
        selectionImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        customBackgroundView.applyDropShadow(color: .init(hex: "2583FF"), opacity: 0.53, offset: .init(width: 0, height: 4), radius: 9)
    }

    private func animateSelection(toLeft: Bool) {
        let offset = toLeft ? 8 : containerView.frame.width / 2
        selectionLeftConstraint?.update(offset: offset)
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
        
        updateColors()
    }

    private func updateColors() {
        leftButton.setTitleColor(isLeftSelected ? .white : .init(hex: "B2B2B2"), for: .normal)
        rightButton.setTitleColor(isLeftSelected ? .init(hex: "B2B2B2") : .white, for: .normal)
    }

    @objc private func leftTapped() {
        guard !isLeftSelected else { return }
        isLeftSelected = true
        animateSelection(toLeft: true)
        onLeftSelected?()
    }

    @objc private func rightTapped() {
        guard isLeftSelected else { return }
        isLeftSelected = false
        animateSelection(toLeft: false)
        onRightSelected?()
    }

    func setSelectedIndex(_ index: Int) {
        isLeftSelected = (index == 0)
        animateSelection(toLeft: isLeftSelected)
    }
}
