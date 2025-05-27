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
                title: "Stay multitasking".localized,
                higlitedTexts: ["multitasking".localized],
                subtitle: "Watch all in one, no need to switch between tabs".localized,
                rating: false
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_1" : "onboarding_1"),
                title: "Keep favorites".localized,
                higlitedTexts: ["favorites".localized],
                subtitle: "Mark your favorite pages to keep them in library".localized,
                rating: true
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_2" : "onboarding_2"),
                title: "We value feedback".localized,
                higlitedTexts: ["feedback".localized],
                subtitle: "Your thoughts on our app help us improve your experience".localized,
                rating: false
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_3" : "onboarding_3"),
                title: "Landscape mode".localized,
                higlitedTexts: ["Landscape".localized],
                subtitle: "Flip your phone over and move the screens as it suits you.".localized,
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
