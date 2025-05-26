import RealmSwift
import Foundation

final class FavoritePage: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var url: String
    @Persisted var iconData: Data
    @Persisted var createdAt: Date
    @Persisted var isFavorite: Bool
}

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

extension RealmManager {
    
    func fetchFavorites() -> Results<FavoritePage> {
        return realm.objects(FavoritePage.self).filter("isFavorite == true").sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func fetchRecents() -> Results<FavoritePage> {
        return realm.objects(FavoritePage.self).sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func delete(_ page: FavoritePage) {
        performRealmWrite { realm in
            if let object = realm.object(ofType: FavoritePage.self, forPrimaryKey: page.id) {
                realm.delete(object)
            }
        }
    }
    
    func addOrUpdate(_ page: FavoritePage) {
        performRealmWrite { realm in
            realm.add(page, update: .modified)
        }
    }
}

extension RealmManager {
    
    func saveVisit(url: String, title: String, iconData: Data?) {
        performRealmWrite { realm in
            let page = FavoritePage()
            page.url = url
            page.title = title
            page.iconData = iconData ?? Data()
            page.createdAt = Date()
            page.isFavorite = false
            realm.add(page)
        }
    }
}
