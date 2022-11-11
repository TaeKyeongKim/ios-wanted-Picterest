//
//  SceneDelegate.swift
//  Picterest
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  let appDIContainer = AppDIContainer()
  var appFlowCoordinator: AppFlowCoordinator?
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    window.backgroundColor = .white
    let tabBarController = UITabBarController()
    window.rootViewController = tabBarController
    appFlowCoordinator = AppFlowCoordinator(tabBarController: tabBarController,
                                            appDIContainer: appDIContainer)
    appFlowCoordinator?.start()
    window.makeKeyAndVisible()
    self.window = window
  }

}

