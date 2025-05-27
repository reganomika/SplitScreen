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
    private var leftWidthConstraint: Constraint?
    
    private var isLandscape: Bool {
        return view.bounds.width > view.bounds.height
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateLayout(for: size)
        })
    }

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
    
    private var lastOrientation: UIDeviceOrientation?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lastOrientation = UIDevice.current.orientation
        updateLayout(for: view.bounds.size)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let current = UIDevice.current.orientation
        guard current.isValidInterfaceOrientation, current != lastOrientation else { return }

        lastOrientation = current
        updateLayout(for: view.bounds.size)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLayout(for: view.bounds.size)

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

        if isLandscape {
            guard let constraint = leftWidthConstraint else { return }
            let currentWidth = constraint.layoutConstraints.first?.constant ?? 0
            let newWidth = max(100, min(currentWidth + translation.x, view.bounds.width - 100))
            constraint.update(offset: newWidth)
        } else {
            guard let constraint = topHeightConstraint else { return }
            let currentHeight = constraint.layoutConstraints.first?.constant ?? 0
            let newHeight = max(100, min(currentHeight + translation.y, view.bounds.height - 100))

            constraint.update(offset: newHeight)
        }

        view.layoutIfNeeded()
    }

    func openPage(urlString: String, position: SplitScreenPosition) {
        let controller = position == .top ? topPanelController : bottomPanelController
        controller.openWebsite(urlString: urlString)
    }
    
    private func updateLayout(for size: CGSize) {
        let isLandscape = size.width > size.height

        topHeightConstraint?.deactivate()
        leftWidthConstraint?.deactivate()

        topContainer.snp.removeConstraints()
        bottomContainer.snp.removeConstraints()
        splitBar.snp.removeConstraints()

        if isLandscape {
            imageView.image = UIImage(named: "handlerVertical")

            topContainer.snp.makeConstraints {
                leftWidthConstraint = $0.width.equalTo(size.width / 2).priority(.high).constraint
                $0.left.top.bottom.equalToSuperview()
            }

            splitBar.snp.makeConstraints {
                $0.left.equalTo(topContainer.snp.right)
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(19)
            }

            bottomContainer.snp.makeConstraints {
                $0.left.equalTo(splitBar.snp.right)
                $0.top.bottom.right.equalToSuperview()
            }

            backgroundImageView.snp.remakeConstraints {
                $0.width.equalTo(7)
                $0.top.bottom.equalToSuperview()
                $0.centerX.equalToSuperview()
            }

            imageView.snp.remakeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(19)
                $0.height.equalTo(85)
            }

        } else {
            imageView.image = UIImage(named: "handler")

            topContainer.snp.makeConstraints {
                topHeightConstraint = $0.height.equalTo(size.height / 2).constraint
                $0.left.right.top.equalToSuperview()
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

            backgroundImageView.snp.remakeConstraints {
                $0.height.equalTo(7)
                $0.left.right.equalToSuperview()
                $0.centerY.equalToSuperview()
            }

            imageView.snp.remakeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(85)
                $0.height.equalTo(19)
            }
        }

        view.layoutIfNeeded()
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
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]
//    }
}
