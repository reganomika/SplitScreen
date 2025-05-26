import UIKit
import WebKit
import SnapKit
import RealmSwift

final class WebPanelController: UIViewController {

    private let addressBarView = AddressBarView()
    private let collectionView: UICollectionView
    private let webView = WKWebView()
    private var isWebVisible = false

    private let sites: [(name: String, url: String, icon: UIImage?)] = [
        ("Google", "https://www.google.com", UIImage(named: "google")),
        ("YouTube", "https://www.youtube.com", UIImage(named: "youtube")),
        ("Facebook", "https://www.facebook.com", UIImage(named: "facebook")),
        ("Instagram", "https://www.instagram.com", UIImage(named: "instagram")),
        ("X", "https://www.twitter.com", UIImage(named: "x")),
        ("Amazon", "https://www.amazon.com", UIImage(named: "amazon"))
    ]

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.itemSize = CGSize(width: 64, height: 90)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        addressBarView.delegate = self
        addressBarView.setText("")
        addressBarView.isWebVisible = false

        view.addSubview(addressBarView)
        view.addSubview(collectionView)
        view.addSubview(webView)

        addressBarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.left.right.equalToSuperview().inset(18)
            $0.height.equalTo(46)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(addressBarView.snp.bottom).offset(12)
            $0.left.right.bottom.equalToSuperview()
        }

        webView.isHidden = true
        webView.navigationDelegate = self
        webView.snp.makeConstraints {
            $0.top.equalTo(addressBarView.snp.bottom).offset(12)
            $0.left.right.bottom.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SiteIconCell.self, forCellWithReuseIdentifier: SiteIconCell.identifier)
    }

    func openWebsite(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        addressBarView.setText(url.host ?? urlString)
        addressBarView.isWebVisible = true
        webView.isHidden = false
        collectionView.isHidden = true
        webView.load(URLRequest(url: url))
    }

    private func showIconsAgain() {
        webView.stopLoading()
        webView.isHidden = true
        collectionView.isHidden = false
        addressBarView.isWebVisible = false
    }

    private func checkIfFavorite(url: String) {
        let isFav = RealmManager.shared.fetchFavorites().contains(where: { $0.url == url })
        addressBarView.isFavorite = isFav
    }

    private func loadFavicon(for url: URL, completion: @escaping (Data?) -> Void) {
        let domain = url.host ?? ""
        let faviconURL = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(domain)")!
        URLSession.shared.dataTask(with: faviconURL) { data, _, _ in
            completion(data)
        }.resume()
    }
}

// MARK: - CollectionView

extension WebPanelController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SiteIconCell.identifier, for: indexPath) as! SiteIconCell
        let site = sites[indexPath.item]
        cell.configure(name: site.name, icon: site.icon)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let site = sites[indexPath.item]
        openWebsite(urlString: site.url)
    }
}

// MARK: - AddressBarViewDelegate

extension WebPanelController: AddressBarViewDelegate {
    func addressBarDidTapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if webView.canGoBack {
            webView.goBack()
        } else {
            addressBarView.isFavorite = false
            addressBarView.setText("")
            showIconsAgain()
        }
    }

    func addressBarDidTapReload() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        webView.reload()
    }

    func addressBarDidTapClear() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        addressBarView.setText("")
    }

    func addressBarDidTapFavorite() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let url = webView.url else { return }
        let urlString = url.absoluteString
        
        let title = self.webView.title ?? "Untitled"

        if let existing = RealmManager.shared.fetchFavorites().first(where: { $0.url == urlString }) {
            RealmManager.shared.delete(existing)
            addressBarView.isFavorite = false
        } else {
            loadFavicon(for: url) { data in
                let page = FavoritePage()
                page.url = urlString
                page.title = title
                page.iconData = data ?? Data()
                page.createdAt = Date()
                page.isFavorite = true
                RealmManager.shared.addOrUpdate(page)
                DispatchQueue.main.async {
                    self.addressBarView.isFavorite = true
                }
            }
        }
    }

    func addressBarDidTapShare() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let url = webView.url else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true)
    }

    func addressBarTextDidChange(_ text: String) {}
    
    func addressBarDidSubmitSearch(_ query: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        var urlString: String
        if trimmed.contains(" ") || !trimmed.contains(".") {
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString = "https://www.google.com/search?q=\(encoded)"
        } else if trimmed.hasPrefix("http") {
            urlString = trimmed
        } else {
            urlString = "https://\(trimmed)"
        }

        openWebsite(urlString: urlString)
    }
}

// MARK: - WKNavigationDelegate

extension WebPanelController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        addressBarView.setText(url.host ?? url.absoluteString)
        checkIfFavorite(url: url.absoluteString)

        let title = webView.title ?? "Untitled"
        loadFavicon(for: url) { data in
            RealmManager.shared.saveVisit(url: url.absoluteString, title: title, iconData: data)
        }
        
        Storage.shared.buttonsTapNumber += 1
        
        if Storage.shared.buttonsTapNumber > 5, !Storage.shared.wasReviewScreen {
            UIApplication.topViewController()?.presentCrossDissolve(vc: ReviewController())
        }
    }
}
