//
//  SceneDIContainer.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/07.
//

import Foundation
import UIKit

final class SceneDIContainer {
  
  struct Dependencies {
    let defaultNetworkSerivce: NetworkService
    let imageNetworkService: NetworkService
  }
  
  //MARK: - Persistent Storage & Network Dependency
  lazy var imageStorage: ImagePersistentStorage = CoreDataImagePersistentStorage()
  private let dependencies: Dependencies

  init(dependencies: Dependencies){
    self.dependencies = dependencies
  }
  
  //MARK: Use Case
  
  func makeFetchImageUsecase() -> FetchImageUsecase {
    return DefaultFetchImageUsecase(imageRespository: makeImageRepository())
  }
  
  func makeLikeImageUsecase() -> UpdateImageLikeStateUsecase {
    return LikeImageUsecase(repository: makeImageRepository())
  }
  
  func makeUndoLikeImageUsecase() -> UpdateImageLikeStateUsecase {
    return UndoLikeImageUsecase(repository: makeImageRepository())
  }
  
  //MARK: Repository
  func makeImageRepository() -> ImageRepository {
    return DefualtImageRepository(persistenStorage: imageStorage, defaultNetworkService: dependencies.defaultNetworkSerivce)
  }
  
  func makeThumbnailImageRepository() -> ThumbnailImagesRepository {
    return DefualtThumbnailImagesRepository(imageDataNetworkService: dependencies.imageNetworkService)
  }
  
  //MARK: Scenes
  func makeHomeViewController() -> HomeViewController {
    return HomeViewController(viewModel: makeHomeViewModel(), thumbnailImageRepository: makeThumbnailImageRepository(), collectionViewCustomLayout: makeHomeCollectionViewLayout())
  }
  
  func makeHomeViewModel() -> HomeViewModel {
    return DefaultHomeViewModel(fetchImageUsecase: makeFetchImageUsecase(), likeImageUsecase: makeLikeImageUsecase(), imagesPerPage: HomeScene.mainContent.numberOfItemsPerPage)
  }
  
  func makeSaveViewController() -> SaveViewController {
    return SaveViewController(viewModel: makeSaveViewModel(), thumbnailImageRepository: makeThumbnailImageRepository(), collectionViewCustomLayout: makeSaveCollectionViewLayout())
  }
  
  func makeSaveViewModel() -> SaveViewModel {
    return DefaultSaveViewModel(fetchImageUsecase: makeFetchImageUsecase(), likeImageUescase: makeUndoLikeImageUsecase())
  }

  //MARK: CollectionViewLayout
  func makeHomeCollectionViewLayout() -> CustomLayout {
    return CustomLayout(layoutConfigurator: makeHomeLayoutConfigurator())  
  }
  
  func makeSaveCollectionViewLayout() -> CustomLayout {
    return CustomLayout(layoutConfigurator: makeSaveLayoutConfigurator())
  }
  
  func makeHomeLayoutConfigurator() -> LayoutConfigurator {
    return LayoutConfigurator(numberOfColumns: HomeScene.mainContent.numberOfColumns, section: HomeScene.mainContent.rawValue, cellPadding: 6, cacheOptions: [.items,.footer], numberOfItemsPerPage: HomeScene.mainContent.numberOfItemsPerPage)
  }
  
  func makeSaveLayoutConfigurator() -> LayoutConfigurator {
    return LayoutConfigurator(numberOfColumns: SaveScene.mainContent.numberOfColumns, section: SaveScene.mainContent.rawValue, cellPadding: 6, cacheOptions: [.items], numberOfItemsPerPage: SaveScene.mainContent.numberOfItemsPerPage)
  }
  
  //MARK: FlowCoordinator
  func makeFlowCoordinator(tabBarController: UITabBarController) -> FlowCoordinator {
    return FlowCoordinator(tabBarController: tabBarController, dependencies: self)
  }
  
  
}

extension SceneDIContainer: FlowCoordinatorDependencies {}

fileprivate enum SaveScene: Int, CaseIterable {
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

fileprivate enum HomeScene: Int, CaseIterable {
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
