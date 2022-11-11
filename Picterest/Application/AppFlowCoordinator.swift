//
//  AppFlowCoordinator.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/08.
//


import UIKit

protocol FlowCoordinatable {
  func start()
}

final class AppFlowCoordinator: FlowCoordinatable {
  
  var tabBarController: UITabBarController
  private var appDIContainer: AppDIContainer
  
  init(tabBarController: UITabBarController, appDIContainer: AppDIContainer){
    self.tabBarController = tabBarController
    self.appDIContainer = appDIContainer
  }
  
  func start() {
    let sceneDIContainer = appDIContainer.makeSceneDIContainer()
    let flow = sceneDIContainer.makeFlowCoordinator(tabBarController: tabBarController)
    flow.start()
  }

}
