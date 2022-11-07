//
//  TabBarController.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/28.
//

import UIKit

final class TabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewControllers = setTabBarItems(tarBarItems: .home, .save)
  }
}

private extension TabBarController {
  
  func setTabBarItems (tarBarItems: TabBarItemComponent...) -> [UIViewController] {
    var items: [UIViewController] = []
    for (index, components) in tarBarItems.enumerated() {
      let item = components.viewController
      item.tabBarItem = UITabBarItem(title: components.title, image: components.image, tag: index)
      items.append(item)
    }
    return items
  }
  
  
  
  enum TabBarItemComponent {
    case home
    case save
    var viewController: UIViewController {
      switch self {
      case .home:
        return HomeViewController(viewModel:
                                    DefaultHomeViewModel(fetchImageUsecase:
                                                          DefaultFetchImageUsecase(imageRespository:
                                                                                    DefualtImageRepository(persistentManager: CoreDataManager())),likeImageUsecase:
                                                          LikeImageUsecase(repository:
                                                                            DefualtImageRepository(persistentManager: CoreDataManager())), imagesPerPage: HomeSection.mainContent.numberOfItemsPerPage),
                                  collectionViewCustomLayout:
                                    CustomLayout(layoutConfigurator:
                                                  LayoutConfigurator(numberOfColumns: HomeSection.mainContent.numberOfColumns, section: HomeSection.mainContent.rawValue, cellPadding: 6, cacheOptions: [.items,.footer], numberOfItemsPerPage: HomeSection.mainContent.numberOfItemsPerPage)))
      case .save:
        return SaveViewController(viewModel: DefaultSaveViewModel(fetchImageUsecase:
                                                                    DefaultFetchImageUsecase(imageRespository:
                                                                                              DefualtImageRepository(persistentManager: CoreDataManager())), likeImageUescase:
                                                                    UndoLikeImageUsecase(repository: DefualtImageRepository(persistentManager: CoreDataManager()))), collectionViewCustomLayout:
                                    CustomLayout(layoutConfigurator:
                                                  LayoutConfigurator(numberOfColumns:
                                                                      SaveSection.mainContent.numberOfColumns, section: SaveSection.mainContent.rawValue, cellPadding: 6, cacheOptions: [.items], numberOfItemsPerPage: SaveSection.mainContent.numberOfItemsPerPage)))
      }
    }
    
    var image: UIImage? {
      switch self {
      case .home:
        return UIImage(systemName: "photo.on.rectangle.angled")
      case .save:
        return UIImage(systemName: "heart")
      }
    }
    
    var title: String{
      switch self {
      case .home:
        return "Images"
      case .save:
        return "Saved"
      }
    }
  }
}


fileprivate enum SaveSection: Int, CaseIterable {
  case mainContent
  
  var numberOfColumns: Int {
    switch self {
    case .mainContent:
      return 1
    }
  }
  
  var numberOfItemsPerPage: Int? {
    switch self {
    case .mainContent:
      return nil
    }
  }

}

fileprivate enum HomeSection: Int, CaseIterable {
  case mainContent
  
  var numberOfColumns: Int {
    switch self {
    case .mainContent:
      return 2
    }
  }
  
  var numberOfItemsPerPage: Int {
    switch self {
    case .mainContent:
      return 15
    }
  }

}
