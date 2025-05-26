import UIKit
import SnapKit
import Utilities

final class TabBarController: UIViewController {

    private lazy var tabBarView: TabBarView = {
        let view = TabBarView()
        view.delegate = self
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let viewControllers = [
        UINavigationController(rootViewController: SplitScreenController()),
        UINavigationController(rootViewController: FavoritesController()),
        UINavigationController(rootViewController: AppSettingsViewController())
    ]
    
    private var currentViewController: UIViewController?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Storage.shared.needSkipOnboarding = true

        setupView()
        setupConstraints()
        
        switchToViewController(0)
    }
    
    private func setupView() {
        view.addSubview(tabBarView)
    }

    private func setupConstraints() {
        
        tabBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIDevice.current.hasHomeButton ? 68 : 102)
        }
    }

    func switchToViewController(_ index: Int) {
        
        tabBarView.updateSelectedButton(at: index)
        
        let newViewController = viewControllers[index]
        
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()

        addChild(newViewController)
        
        view.insertSubview(newViewController.view, belowSubview: tabBarView)
        
        newViewController.view.frame = view.bounds
        newViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newViewController.didMove(toParent: self)

        currentViewController = newViewController
    }
}

extension TabBarController: TabBarViewDelegate {
    
    func tabBarView(_ tabBarView: TabBarView, didSelectItemAt index: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
      
        switchToViewController(index)
    }
}
