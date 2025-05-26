import RealmSwift
import Foundation


final class RealmManager {
    static let shared = RealmManager()
    private let realm = try! Realm()
    
    private func performRealmWrite(_ completion: @escaping (Realm) -> Void) {
        DispatchQueue.main.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        completion(realm)
                    }
                } catch {
                    print("Ошибка при записи в Realm: \(error)")
                }
            }
        }
    }

}
