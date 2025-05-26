import UIKit
import PremiumManager

final class PaywallManager {
    static let shared = PaywallManager()
    
    func getPaywall(isFromOnboarding: Bool = false) -> UIViewController {
        let vc = PaywallController(isFromOnboarding: isFromOnboarding)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    func showPaywall() {
        UIApplication.topViewController()?.present(vc: getPaywall(isFromOnboarding: false))
    }
}
