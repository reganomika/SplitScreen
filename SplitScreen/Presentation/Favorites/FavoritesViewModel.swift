import Foundation
import RealmSwift

enum SplitScreenPosition {
    case top
    case bottom
}

enum SegmentType: Int {
    case favorites = 0
    case recent = 1
}

final class FavoritesViewModel {
    
    private(set) var items: [FavoritePage] = []
    private var notificationToken: NotificationToken?
    private var currentSegment: SegmentType = .favorites
    var onItemsUpdated: (() -> Void)?

    init() {
        load()
    }

    func setSegment(_ index: Int) {
        guard let segment = SegmentType(rawValue: index) else { return }
        currentSegment = segment
        load()
    }

    private func load() {
        notificationToken?.invalidate()
        
        let results: Results<FavoritePage>
        switch currentSegment {
        case .favorites:
            results = RealmManager.shared.fetchFavorites()
        case .recent:
            results = RealmManager.shared.fetchRecents()
        }

        notificationToken = results.observe { [weak self] changes in
            switch changes {
            case .initial(let collection), .update(let collection, _, _, _):
                self?.items = Array(collection)
                self?.onItemsUpdated?()
            case .error(let error):
                print("Realm error: \(error)")
            }
        }
    }

    func delete(_ item: FavoritePage) {
        RealmManager.shared.delete(item)
    }
    
    func shareURL(_ item: FavoritePage) -> URL? {
        return URL(string: item.url)
    }
}
