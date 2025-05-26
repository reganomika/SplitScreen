import UIKit
import PremiumManager
import RealmSwift
import ShadowImageButton

final class FavoritesController: BaseController {

    private let viewModel = FavoritesViewModel()
    private let tableView = UITableView()
    private let navigationTitle = UILabel()

    private let emptyStateView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureTableView()
        bindViewModel()
    }

    private func configureNavigation() {
        navigationTitle.text = "Favorites".localized
        navigationTitle.font = .font(weight: .bold, size: 22)
        configurNavigation(leftView: navigationTitle)
    }

    private func configureTableView() {
        
    }

    private func bindViewModel() {

    }

}
