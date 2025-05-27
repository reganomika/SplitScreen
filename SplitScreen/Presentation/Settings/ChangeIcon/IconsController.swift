import UIKit
import SnapKit
import CustomBlurEffectView
import Utilities

// MARK: - Icon Model

enum Icon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case first = "AppIcon-1"
    
    private enum Constants {
        static let primaryImageName = "playstore"
        static let firstImageName = "playstore-1"
    }
    
    var image: UIImage? {
        switch self {
        case .primary: return UIImage(named: Constants.primaryImageName)
        case .first: return UIImage(named: Constants.firstImageName)
        }
    }
    
    var id: String { rawValue }
}

// MARK: - IconsController

final class IconsController: UIViewController {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let blurRadius: CGFloat = 3
        static let blurColor = UIColor(hex: "171313")
        static let blurAlpha: CGFloat = 0.3
        
        static let contentBackground = UIColor.white
        static let cornerRadius: CGFloat = 28
        static let contentHeight: CGFloat = 328
        
        static let titleFontSize: CGFloat = 20
        static let titleTopInset: CGFloat = 30
        static let horizontalInset: CGFloat = 22
        
        static let closeButtonSize: CGFloat = 24
        static let closeButtonInset: CGFloat = 24
        static let closeButtonRightInset: CGFloat = 24
        
        static let collectionViewHeight: CGFloat = 164
        static let collectionViewBottomInset: CGFloat = 82
        static let collectionViewTotalWidth: CGFloat = 358
        static let itemSize: CGFloat = 164
        static let minimumLineSpacing: CGFloat = 30
        
    }
    
    // MARK: - Properties
    
    private let icons = Icon.allCases
    private var selectedIndexPaths: [IndexPath] = []
    
    // MARK: - UI Components
    
    private lazy var blurView = CustomBlurEffectView().apply {
        $0.blurRadius = LayoutConstants.blurRadius
        $0.colorTint = LayoutConstants.blurColor
        $0.colorTintAlpha = LayoutConstants.blurAlpha
    }
    
    private lazy var contentView = UIView().apply {
        $0.backgroundColor = LayoutConstants.contentBackground
        $0.layer.cornerRadius = LayoutConstants.cornerRadius
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private lazy var titleLabel = UILabel().apply {
        $0.text = "Choose your icon".localized
        $0.font = .font(weight: .bold, size: LayoutConstants.titleFontSize)
        $0.textColor = .init(hex: "303030")
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var closeButton = UIButton().apply {
        $0.setImage(UIImage(named: "close"), for: .normal)
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = LayoutConstants.minimumLineSpacing
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout).apply {
            $0.delegate = self
            $0.dataSource = self
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.register(IconCell.self, forCellWithReuseIdentifier: IconCell.identifier)
        }
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupInitialSelection()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(blurView)
        blurView.addSubview(contentView)
        contentView.addSubviews(titleLabel, closeButton, collectionView)
    }
    
    private func setupConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(LayoutConstants.contentHeight)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(LayoutConstants.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(LayoutConstants.horizontalInset)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(LayoutConstants.closeButtonSize)
            $0.top.equalToSuperview().inset(LayoutConstants.closeButtonInset)
            $0.trailing.equalToSuperview().inset(LayoutConstants.closeButtonRightInset)
        }
        
        let horizontalInset = (UIScreen.main.bounds.width - LayoutConstants.collectionViewTotalWidth) / 2
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(horizontalInset)
            $0.bottom.equalToSuperview().inset(LayoutConstants.collectionViewBottomInset)
            $0.height.equalTo(LayoutConstants.collectionViewHeight)
        }
    }
    
    // MARK: - Selection Handling
    
    private func setupInitialSelection() {
        let currentIconName = UIApplication.shared.alternateIconName
        if let index = icons.firstIndex(where: { $0.rawValue == currentIconName ?? Icon.primary.rawValue }) {
            selectedIndexPaths = [IndexPath(item: index, section: 0)]
        }
        collectionView.reloadData()
    }
    
    private func handleIconSelection(at indexPath: IndexPath) {
        guard !selectedIndexPaths.contains(indexPath) else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let previousIndexPath = selectedIndexPaths.first
        selectedIndexPaths = [indexPath]
        
        changeAppIcon(to: icons[indexPath.row])
        
        var indexPathsToUpdate = [indexPath]
        if let previousIndexPath = previousIndexPath {
            indexPathsToUpdate.append(previousIndexPath)
        }
        
        collectionView.reloadItems(at: indexPathsToUpdate)
    }
    
    // MARK: - Icon Change
    
    private func changeAppIcon(to icon: Icon) {
        let iconName: String? = (icon != .primary) ? icon.rawValue : nil
        
        guard UIApplication.shared.alternateIconName != iconName else { return }
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("App icon change failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss(animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension IconsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: IconCell.identifier,
            for: indexPath
        ) as! IconCell
        
        let icon = icons[indexPath.row]
        let isSelected = selectedIndexPaths.contains(indexPath)
        cell.configure(with: icon.image, isSelected: isSelected)
        
        return cell
    }
}

extension IconsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleIconSelection(at: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension IconsController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: LayoutConstants.itemSize,
            height: LayoutConstants.itemSize
        )
    }
}


final class IconCell: UICollectionViewCell {
    
    static let identifier = "IconCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.layer.cornerRadius = 24
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with icon: UIImage?, isSelected: Bool) {
        
        imageView.image = icon
        
        if isSelected {
            contentView.applyGradientBorder(
                colors: [UIColor(hex: "325FFA"), UIColor(hex: "38C2FE")],
                lineWidth: 8,
                cornerRadius: 24
            )
        } else {
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 1
            contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }
}
