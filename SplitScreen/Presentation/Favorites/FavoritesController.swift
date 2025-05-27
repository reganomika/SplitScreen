import UIKit
import SnapKit
import RealmSwift

final class FavoritesController: BaseController {
    
    private let viewModel = FavoritesViewModel()
    
    private let navigationTitle = UILabel()
    private let segmentedControlView = SegmentedControlView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateView = UIView()
    
    private var emptyStateHeightConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        setupTableView()
        setupSegmentedControl()
        setupEmptyStateView()
        bindViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let isLandscape = view.bounds.width > view.bounds.height
        let newHeight: CGFloat = isLandscape ? 220 : 327

        emptyStateHeightConstraint?.update(offset: newHeight)
    }

    private func configureNavigation() {
        navigationTitle.text = "Favorites".localized
        navigationTitle.font = .font(weight: .bold, size: 22)
        configurNavigation(leftView: navigationTitle)
    }

    private func setupSegmentedControl() {
        view.addSubview(segmentedControlView)
        segmentedControlView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(73)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.left.right.equalToSuperview().inset(24)
        }
    }

    private func setupTableView() {
        tableView.register(FavoritesCell.self, forCellReuseIdentifier: FavoritesCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 92
        tableView.contentInset.bottom = 100
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(144)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }

    private func setupEmptyStateView() {
        let iconView = UIImageView(image: UIImage(named: "empty"))
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "You don’t have any pages yet".localized
        titleLabel.font =  .font(weight: .semibold, size: 18)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .init(hex: "303030")
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Use Split Screen to see them here".localized
        subtitleLabel.font = .font(weight: .medium, size: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .init(hex: "B2B2B2")
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(24, after: iconView)
        
        emptyStateView.addSubview(stack)
        view.addSubview(emptyStateView)

        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        iconView.snp.makeConstraints {
            $0.width.equalTo(109)
            $0.height.equalTo(94)
        }

        emptyStateView.snp.makeConstraints {
            emptyStateHeightConstraint = $0.height.equalTo(327).constraint
            $0.left.right.equalToSuperview().inset(24)
            $0.top.equalTo(segmentedControlView.snp.bottom).inset(-20)
        }
        
        emptyStateView.backgroundColor = .white
        emptyStateView.layer.cornerRadius = 16

        emptyStateView.isHidden = !RealmManager.shared.fetchFavorites().isEmpty
    }

    private func bindViewModel() {
        viewModel.onItemsUpdated = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.emptyStateView.isHidden = !self.viewModel.items.isEmpty
            self.tableView.isHidden = self.viewModel.items.isEmpty
        }
        
        segmentedControlView.onLeftSelected = { [weak self] in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self?.viewModel.setSegment(0)
        }

        segmentedControlView.onRightSelected = { [weak self] in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self?.viewModel.setSegment(1)
        }
    }

    private func presentActions(for item: FavoritePage) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share".localized, style: .default, handler: { _ in
            if let url = self.viewModel.shareURL(item) {
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.present(activity, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: { _ in
            self.viewModel.delete(item)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FavoritesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesCell.identifier, for: indexPath) as? FavoritesCell else {
            return UITableViewCell()
        }

        let model = viewModel.items[indexPath.row]
        cell.configure(with: model)
        cell.configureCorners(at: indexPath.row, rowCount: viewModel.items.count)
        cell.onActionTapped = { [weak self] in
            self?.presentActions(for: model)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavoritesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let item = viewModel.items[indexPath.row]
        
        let alert = UIAlertController(title: "Open Page".localized, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Open at top".localized, style: .default, handler: { _ in
            self.openPage(item, at: .top)
        }))
        
        alert.addAction(UIAlertAction(title: "Open at bottom".localized, style: .default, handler: { _ in
            self.openPage(item, at: .bottom)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        
        present(alert, animated: true)
    }

    private func openPage(_ item: FavoritePage, at position: SplitScreenPosition) {
        guard let tabbar = parent?.parent as? TabBarController else { return }
        tabbar.switchToViewController(0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let splitVC = tabbar.viewControllers[0].viewControllers.first as? SplitScreenController {
                splitVC.openPage(urlString: item.url, position: position)
            }
        }
    }
}
