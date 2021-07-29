//
//  CompostionalController.swift
//  AppStoreClone
//
//  Created by Pradeep Gianchandani on 29/07/21.
//

import SwiftUI

class CompositionalController: UICollectionViewController {
    
    init() {
        
        let layout = UICollectionViewCompositionalLayout { (sectionNumber, _) -> NSCollectionLayoutSection? in
            
            if sectionNumber == 0 {
                return CompositionalController.topSection()
            } else {
                // second section
                // Here we create a group which is 80% of screen size and 300 points in height
                // Item added within the group fills 100% of width and 33.33% of height within the group
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3)))
                item.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 16)
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(300)), subitems: [item])
                 
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets.leading = 16
                
                // add header layout to the section
                let kind = UICollectionView.elementKindSectionHeader
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: kind, alignment: .topLeading)
                ]
                
                return section
            }
        }
        
        super.init(collectionViewLayout: layout)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CompositionalHeader
        var title: String?
        if indexPath.section == 1 {
            title = games?.feed.title
        } else if indexPath.section == 2 {
            title = topGrossingApps?.feed.title
        } else {
            title = freeApps?.feed.title
        }
        header.label.text = title
        return header
    }
    
    static func topSection() -> NSCollectionLayoutSection {
        
        // Here we create a group which is 80% of screen size and 300 points in height
        // Item added within the group fills 100% of space with content inset of 16 pixels (bottom and trailing)
        // Add group within the section
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets.bottom = 16
        item.contentInsets.trailing = 16
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(300)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets.leading = 16
        return section
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var socialApps = [SocialApp]()
    var games: AppGroup?
    var topGrossingApps: AppGroup?
    var freeApps: AppGroup?
    
    class CompositionalHeader: UICollectionReusableView {
        
        let label = UILabel(text: "Editor's Choice Games", font: .boldSystemFont(ofSize: 32))
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(label)
            label.fillSuperview()
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
    }
    
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CompositionalHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(AppsHeaderCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(AppItemCell.self, forCellWithReuseIdentifier: "smallCellId")
        collectionView.backgroundColor = .systemBackground
        navigationItem.title = "Apps"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        fetchApps()
        setupDiffableDatasource()
    }
    
    enum AppSection {
        case topSocial
        case grossing
        case games
    }
    
    // This will render data in collection view cells based on the object type
    lazy var diffableDataSource: UICollectionViewDiffableDataSource<AppSection, AnyHashable> = .init(collectionView: self.collectionView) { (collectionView, indexPath, object) -> UICollectionViewCell? in
        
        if let object = object as? SocialApp {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! AppsHeaderCell
            cell.app = object
            
            return cell
        } else if let object = object as? FeedResult {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "smallCellId", for: indexPath) as! AppItemCell
            cell.app = object
            cell.getButton.addTarget(self, action: #selector(self.handleGet), for: .primaryActionTriggered)
            
            return cell
        }
        
        return nil
    }
    
    @objc func handleGet(button: UIView) {
//        print(123)
        
        var superview = button.superview
        
        // i want to reach the parent cell of the get button
        while superview != nil {
            if let cell = superview as? UICollectionViewCell {
                guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
                guard let objectIClickedOnto = diffableDataSource.itemIdentifier(for: indexPath) else { return }
                
                var snapshot = diffableDataSource.snapshot()
                snapshot.deleteItems([objectIClickedOnto])
                diffableDataSource.apply(snapshot)
                
                print(objectIClickedOnto)
            }
            superview = superview?.superview
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let object = diffableDataSource.itemIdentifier(for: indexPath)
        if let object = object as? SocialApp {
            let appDetailController = AppDetailController(appId: object.id)
            navigationController?.pushViewController(appDetailController, animated: true)
        } else if let object = object as? FeedResult {
            let appDetailController = AppDetailController(appId: object.id)
            navigationController?.pushViewController(appDetailController, animated: true)
        }
    }
    
    private func setupDiffableDatasource() {
//        collectionView.dataSource = diffableDataSource
        
        diffableDataSource.supplementaryViewProvider = .some({ (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerId, for: indexPath) as! CompositionalHeader
            
            let snapshot = self.diffableDataSource.snapshot()
            if let object = self.diffableDataSource.itemIdentifier(for: indexPath) {
                if let section = snapshot.sectionIdentifier(containingItem: object) {
                    if section == .games {
                        header.label.text = "Games"
                    } else {
                        header.label.text = "Top Grossing"
                    }
                }
            }
            return header
        })
        
        AppstoreAPI.shared.fetchSocialApps { (socialApps, err) in
            AppstoreAPI.shared.fetchTopGrossing { (appGroup, err) in
                AppstoreAPI.shared.fetchGames { (gamesGroup, erro) in
                    var snapshot = self.diffableDataSource.snapshot()

                    // top social
                    snapshot.appendSections([.topSocial, .games, .grossing])
                    snapshot.appendItems(socialApps ?? [], toSection: .topSocial)

//                    snapshot.appendItems(socialApps ?? [], toSection: .topSocial)

                    // top Grossing
                    let objects = appGroup?.feed.results ?? []
                    snapshot.appendItems(objects, toSection: .grossing)

                    snapshot.appendItems(gamesGroup?.feed.results ?? [], toSection: .games)

                    self.diffableDataSource.apply(snapshot)
                }
            }


        }
    }
}

//extension CompositionalController {
//    func fetchAppsSynchronously() {
//        AppstoreAPI.shared.fetchSocialApps { (apps, err) in
//            self.socialApps = apps ?? []
//            AppstoreAPI.shared.fetchGames { (appGroup, err) in
//                self.games = appGroup
//                AppstoreAPI.shared.fetchTopGrossing { (appGroup, err) in
//                    self.topGrossingApps = appGroup
//                    AppstoreAPI.shared.fetchAppGroup(urlString: "https://rss.itunes.apple.com/api/v1/us/ios-apps/top-free/all/25/explicit.json") { (appGroup, err) in
//                        self.freeApps = appGroup
//                        DispatchQueue.main.async {
//                            self.collectionView.reloadData()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
//    func fetchAppsDispatchGroup() {
//        let dispatchGroup = DispatchGroup()
//
//        dispatchGroup.enter()
//        AppstoreAPI.shared.fetchGames { (appGroup, err) in
//            self.games = appGroup
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.enter()
//        AppstoreAPI.shared.fetchTopGrossing { (appGroup, err) in
//            self.topGrossingApps = appGroup
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.enter()
//        AppstoreAPI.shared.fetchAppGroup(urlString: "https://rss.itunes.apple.com/api/v1/us/ios-apps/top-free/all/25/explicit.json") { (appGroup, err) in
//            self.freeApps = appGroup
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.enter()
//        AppstoreAPI.shared.fetchSocialApps { (apps, err) in
//            dispatchGroup.leave()
//            self.socialApps = apps ?? []
//        }
//
//        // completion
//        dispatchGroup.notify(queue: .main) {
//            self.collectionView.reloadData()
//        }
//    }
//}

struct AppsView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<AppsView>) -> UIViewController {
        let controller = CompositionalController()
        return UINavigationController(rootViewController: controller)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AppsView>) {
        
    }
    
    typealias UIViewControllerType = UIViewController
}

struct AppsCompositionalView_Previews: PreviewProvider {
    static var previews: some View {
        AppsView()
            .edgesIgnoringSafeArea(.all)
            .colorScheme(.dark)
    }
}