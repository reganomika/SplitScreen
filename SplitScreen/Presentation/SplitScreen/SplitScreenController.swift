import UIKit
import SnapKit
import CustomBlurEffectView

final class SplitScreenController: BaseController {

    private let mainContainer = UIView()
    private let topContainer = UIView()
    private let splitBar = UIView()
    private let bottomContainer = UIView()

    private let topPanelController = WebPanelController()
    private let bottomPanelController = WebPanelController()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "buttonBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "handler"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private var topHeightConstraint: Constraint?

    // MARK: - Hint UI

    private let hintOverlay = CustomBlurEffectView()
    private let hintBubble = UIImageView(image: UIImage(named: "hintBubble"))

    private let hintIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "arrowIcon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap and drag to change screen position".localized
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .font(weight: .bold, size: 16)
        label.textColor = UIColor(hex: "303030")
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if !Storage.shared.hasSeenSplitScreenShown {
            showSplitHint()
        }
    }

    private func setupUI() {
        topContainer.backgroundColor = UIColor(hex: "EFEFF7")
        bottomContainer.backgroundColor = UIColor(hex: "EFEFF7")

        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        mainContainer.addSubview(topContainer)
        mainContainer.addSubview(bottomContainer)
        mainContainer.addSubview(splitBar)

        splitBar.addSubviews(backgroundImageView, imageView)

        backgroundImageView.snp.makeConstraints {
            $0.height.equalTo(7)
            $0.left.right.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(19)
            $0.width.equalTo(85)
        }

        topContainer.snp.makeConstraints {
            topHeightConstraint = $0.height.equalTo(view.bounds.height / 2).constraint
            $0.top.left.right.equalToSuperview()
        }

        splitBar.snp.makeConstraints {
            $0.top.equalTo(topContainer.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(19)
        }

        bottomContainer.snp.makeConstraints {
            $0.top.equalTo(splitBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        splitBar.addGestureRecognizer(pan)

        embed(topPanelController, into: topContainer)
        embed(bottomPanelController, into: bottomContainer)
    }

    private func embed(_ child: UIViewController, into container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        child.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        child.didMove(toParent: self)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        hideHint()
        let translation = gesture.translation(in: view)
        gesture.setTranslation(.zero, in: view)

        guard let constraint = topHeightConstraint else { return }
        let currentHeight = constraint.layoutConstraints.first?.constant ?? 0
        let newHeight = max(100, min(currentHeight + translation.y, view.bounds.height - 100))

        constraint.update(offset: newHeight)
    }

    func openPage(urlString: String, position: SplitScreenPosition) {
        let controller = position == .top ? topPanelController : bottomPanelController
        controller.openWebsite(urlString: urlString)
    }

    // MARK: - Hint

    private func showSplitHint() {
        hintOverlay.alpha = 0
        hintOverlay.isUserInteractionEnabled = true
        
        mainContainer.insertSubview(hintOverlay, belowSubview: splitBar)
        
        hintOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        hintOverlay.addSubview(hintBubble)
        hintBubble.snp.makeConstraints {
            $0.centerX.equalTo(splitBar)
            $0.bottom.equalTo(splitBar.snp.top).offset(-8)
        }

        hintBubble.addSubview(hintIcon)
        hintBubble.addSubview(hintLabel)

        hintIcon.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview().offset(-8)
            $0.size.equalTo(24)
        }

        hintLabel.snp.makeConstraints {
            $0.left.equalTo(hintIcon.snp.right).offset(8)
            $0.centerY.equalTo(hintIcon)
            $0.right.equalToSuperview().inset(12)
        }

        UIView.animate(withDuration: 0.3) {
            self.hintOverlay.alpha = 1
        }
    }

    @objc private func hideHint() {
        Storage.shared.hasSeenSplitScreenShown = true
        UIView.animate(withDuration: 0.25, animations: {
            self.hintOverlay.alpha = 0
        }, completion: { _ in
            self.hintOverlay.removeFromSuperview()
        })
    }
}
