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
  lazy var defaultNetworkSerivce: NetworkService = {
    let apiConfig = DefaultApiConfiguration(apiKey: appConfiguration.apiKey,
                                            baseURL: appConfiguration.apiBaseURL,
                                            headers: ["Content-Type":"application/json"],
                                            scheme: appConfiguration.httpsScheme)
    return DefaultNetworkService(apiConfig: apiConfig)
  }()
  
  lazy var imageNetworkSerivce: NetworkService = {
    return DefaultNetworkService(apiConfig: nil)
  }()
  
  
  //MARK: Scene dependencies
  func makeSceneDIContainer() -> SceneDIContainer {
    let dependencies = SceneDIContainer.Dependencies(defaultNetworkSerivce: defaultNetworkSerivce, imageNetworkService: imageNetworkSerivce)
    return SceneDIContainer(dependencies: dependencies)
  }
  
  
}


