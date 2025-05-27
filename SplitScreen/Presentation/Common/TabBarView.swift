import UIKit
import SnapKit
import Utilities

protocol TabBarViewDelegate: AnyObject {
    func tabBarView(_ tabBarView: TabBarView, didSelectItemAt index: Int)
}

enum TabBarViewItemType {
    case tabItem(selectedImage: UIImage?, unselectedImage: UIImage?, String)
}

final class TabBarView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()

    weak var delegate: TabBarViewDelegate?
    private var tabButtons: [UIView] = []
    
    private let items: [TabBarViewItemType] = [
        .tabItem(
            selectedImage: UIImage(named: "splitTabSelected"),
            unselectedImage: UIImage(named: "splitTabUnselected"),
            "screen".localized
        ),
        .tabItem(
            selectedImage: UIImage(named: "favoritesTabSelected"),
            unselectedImage: UIImage(named: "favoritesTabUnselected"),
            "Favorites".localized.lowercased()
        ),
        .tabItem(
            selectedImage: UIImage(named: "settingsTabSelected"),
            unselectedImage: UIImage(named: "settingsTabUnselected"),
            "settings".localized
        )
    ]

    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.cornerRadius = 36
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        setupTabBarButtons()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTabBarButtons() {
        for (index, item) in items.enumerated() {
            if case let .tabItem(selectedImage, unselectedImage, title) = item {
                let button = createTabButton(
                    selectedImage: selectedImage,
                    unselectedImage: unselectedImage,
                    title: title,
                    tag: index
                )
                stackView.addArrangedSubview(button)
                tabButtons.append(button)
            }
        }
        updateSelectedButton(at: 0)
    }
    
    private func createTabButton(
        selectedImage: UIImage?,
        unselectedImage: UIImage?,
        title: String,
        tag: Int
    ) -> UIView {
        let container = UIView()
        container.tag = tag
        
        let imageView = UIImageView(image: unselectedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        
        let label = UILabel()
        label.text = title
        label.font = .font(weight: .medium, size: 14)
        label.tag = 101
        
        container.addSubview(imageView)
        container.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabButtonTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        
        return container
    }

    private func setupLayout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(68)
            make.top.equalToSuperview().inset(10)
        }
    }

    @objc private func tabButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedIndex = sender.view?.tag else { return }
        updateSelectedButton(at: selectedIndex)
        delegate?.tabBarView(self, didSelectItemAt: selectedIndex)
    }

   func updateSelectedButton(at index: Int) {
        for (i, item) in items.enumerated() {
            guard case let .tabItem(selectedImage, unselectedImage, _) = item,
                  i < tabButtons.count else { continue }
            
            let button = tabButtons[i]
            let imageView = button.viewWithTag(100) as? UIImageView
            let label = button.viewWithTag(101) as? UILabel
           
            let isSelected = index == i
                        
            imageView?.image = isSelected ? selectedImage : unselectedImage
            label?.textColor = isSelected ? UIColor.init(hex: "227CFA") : UIColor.init(hex: "B2B2B2")
        }
    }
}
