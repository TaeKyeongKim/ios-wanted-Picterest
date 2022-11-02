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
                                                          DefaultFetchImageUsecase(imageRespository: DefualtImageRepository(persistentManager: CoreDataManager())),
                                                         likeImageUsecase:
                                                          LikeImageUsecase(repository:
                                                                            DefualtImageRepository(persistentManager: CoreDataManager()))))
      case .save:
        return SaveViewController(viewModel: DefaultSaveViewModel(fetchImageUsecase: DefaultFetchImageUsecase(imageRespository: DefualtImageRepository(persistentManager: CoreDataManager())), likeImageUescase: UndoLikeImageUsecase(repository: DefualtImageRepository(persistentManager: CoreDataManager()))))
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
