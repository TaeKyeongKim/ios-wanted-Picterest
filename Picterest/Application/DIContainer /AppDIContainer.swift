//
//  AppDIContainer.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/06.
//

import Foundation

//- Setup apiConfigator for DefualtNetworkSerivce
//- DIContainer for Scenes

final class AppDIContainer {
  
  lazy var appConfiguration = AppConfiguration()
  
  //MARK: configure defualtNetworkSerivce
  lazy var defaultNetworkSerivce: DefaultNetworkService = {
    let apiConfig = DefaultApiConfiguration(baseURL: appConfiguration.apiBaseURL,
                                            headers: ["Content-Type":"application/json"],
                                            scheme: appConfiguration.httpsScheme)
    return DefaultNetworkService(apiConfig: apiConfig)
  }()
  
  //MARK: Scene dependencies
  func makeSceneDIContainer() -> SceneDIContainer {
    let dependencies = SceneDIContainer.Dependencies(defaultNetworkSerivce: defaultNetworkSerivce)
    return SceneDIContainer(dependencies: dependencies)
  }
  
  
}


