import UIKit
import WebKit
import FirebaseCore
import PremiumManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        PremiumManager.shared.configure(with: .init(apiKey: Config.apphudKey, debugMode: Config.debugMode))
        PremiumManager.shared.fetchProducts()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }

        application.registerForRemoteNotifications()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PremiumManager.shared.submitPushNotificationsToken(deviceToken: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {}
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        PremiumManager.shared.handlePushNotification(notification: response.notification)
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        PremiumManager.shared.handlePushNotification(notification: notification)
        completionHandler([])
    }
}

extension UILabel {
    func getHighlightedText(_ text: String, with font: UIFont) -> NSMutableAttributedString? {
        guard let labelText = self.text else { return nil }
        
        let attributedString = NSMutableAttributedString(string: labelText)
        let range = (labelText as NSString).range(of: text)
        attributedString.addAttribute(.font, value: font, range: range)
        
        return attributedString
    }
}

extension DateFormatter {
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
}

extension WKWebView {
    func createPDF(completion: @escaping (Data?) -> Void) {
        let config = WKPDFConfiguration()
        self.createPDF(configuration: config) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure:
                completion(nil)
            }
        }
    }
}

extension UIView {
    func applyDropShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}

