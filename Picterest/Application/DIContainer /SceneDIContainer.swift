//
//  SceneDIContainer.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/07.
//

import Foundation

final class SceneDIContainer {
  
  struct Dependencies {
    let defaultNetworkSerivce: NetworkService
  }
  
  private let dependencies: Dependencies

  init(dependencies: Dependencies){
    self.dependencies = dependencies
  }
  
  
  
  
}
