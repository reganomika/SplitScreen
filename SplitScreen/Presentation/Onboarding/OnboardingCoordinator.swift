import UIKit
import Utilities

class OnboardingCoordinator {
    
    private let window: UIWindow
    private var currentIndex = 0
    private let models: [OnboardingModel]
    
    init(window: UIWindow) {
        self.window = window
        self.models = [
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_0" : "onboarding_0"),
                title: "Welcome to Air Printer".localized,
                higlitedTexts: ["Welcome".localized],
                subtitle: "Send photos, docs, and web pages to your printer directly from your phone".localized,
                rating: false
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_1" : "onboarding_1"),
                title: "Smart printer detection".localized,
                higlitedTexts: ["Smart".localized],
                subtitle: "Auto-detecting and connecting to your printer in seconds".localized,
                rating: true
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_2" : "onboarding_2"),
                title: "Share your thoughts with us".localized,
                higlitedTexts: ["Share".localized],
                subtitle: "Your voice matters — help us make the app even better".localized,
                rating: false
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_3" : "onboarding_3"),
                title: "Scan and Edit your files".localized,
                higlitedTexts: ["Scan".localized, "Edit".localized],
                subtitle: "One tap to scan and edit your file in high quality".localized,
                rating: false
            )
        ]
    }
    
    func start() {
        showNextViewController()
    }
    
    private func showNextViewController() {
        guard currentIndex < models.count else {
            transitionToPaywall()
            return
        }
        
        let model = models[currentIndex]
        let viewController = OnboardingController(model: model, coordinator: self)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        currentIndex += 1
    }
    
    func goToNextScreen() {
        showNextViewController()
    }
    
    private func transitionToPaywall() {
        let vc = PaywallManager.shared.getPaywall(isFromOnboarding: true)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
