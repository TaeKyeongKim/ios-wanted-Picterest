//
//  FlowCoordinator.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/08.
//

import UIKit

protocol FlowCoordinatorDependencies {
  func makeHomeViewController() -> HomeViewController
  func makeSaveViewController() -> SaveViewController
}

final class FlowCoordinator {
  
  private weak var tabBarController: UITabBarController?
  private let dependencies: FlowCoordinatorDependencies
  
  private weak var homeVC: HomeViewController?
  private weak var SaveVC: SaveViewController?
  
  init(tabBarController: UITabBarController, dependencies: FlowCoordinatorDependencies) {
    self.tabBarController = tabBarController
    self.dependencies = dependencies
  }
  
  func start() {
    tabBarController?.viewControllers = setTabBarItems(tarBarItems: TabBarItemComponent.homeScene(dependencies),TabBarItemComponent.saveScene(dependencies))
  }
  
  private func setTabBarItems (tarBarItems: TabBarItemComponent...) -> [UIViewController] {
    var items: [UIViewController] = []
    for (index, components) in tarBarItems.enumerated() {
      let item = components.viewController
      item.tabBarItem = UITabBarItem(title: components.title, image: components.image, tag: index)
      items.append(item)
    }
    return items
  }

  fileprivate enum TabBarItemComponent {
    case homeScene(FlowCoordinatorDependencies)
    case saveScene(FlowCoordinatorDependencies)
    
    var viewController: UIViewController {
      switch self {
      case .homeScene(let dependencies):
        return dependencies.makeHomeViewController()
      case .saveScene(let dependencies):
        return dependencies.makeSaveViewController()
      }
    }
    
    var image: UIImage? {
      switch self {
      case .homeScene:
        return UIImage(systemName: "photo.on.rectangle.angled")
      case .saveScene:
        return UIImage(systemName: "heart")
      }
    }
    
    var title: String {
      switch self {
      case .homeScene:
        return "Images"
      case .saveScene:
        return "Saved"
      }
    }
  }
}
