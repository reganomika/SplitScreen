import Foundation
import StorageManager

final class Storage {

    // MARK: - Properties
    
    static let shared = Storage()

    private let storageManager: StorageManager = .shared

    // MARK: - Public Properties

    var needSkipOnboarding: Bool {
        get { storageManager.get(forKey: onboardingShownKey, defaultValue: false) }
        set { storageManager.set(newValue, forKey: onboardingShownKey) }
    }

    var wasReviewScreen: Bool {
        get { storageManager.get(forKey: reviewShownKey, defaultValue: false) }
        set { storageManager.set(newValue, forKey: reviewShownKey) }
    }
    
    var hasSeenSplitScreenShown: Bool {
        get { storageManager.get(forKey: hasSeenSplitScreenHint, defaultValue: false) }
        set { storageManager.set(newValue, forKey: hasSeenSplitScreenHint) }
    }
    
    var buttonsTapNumber: Int {
        get { storageManager.get(forKey: userActionCounterKey, defaultValue: 0) }
        set { storageManager.set(newValue, forKey: userActionCounterKey) }
    }
    
    private let deviceKey = "ConnectedTVDevice"
    private let onboardingShownKey = "onboarding_key_dataBase"
    private let reviewShownKey = "review_key_dataBase"
    private let userActionCounterKey = "user_actions_key_dataBase"
    private let hasSeenSplitScreenHint = "has_seen_split_screen_hint"
}
