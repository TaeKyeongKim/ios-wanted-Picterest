//
//  HomeRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

//Infrastructure layer has to be reconstructed. 
final class DefualtImageRepository {

  private let defaultNetworkService: NetworkService
  private let persistentManager: PersistentManager
  private let decorder = Decoder<[ImageDTO]>()
  
  init(persistentManager: PersistentManager, defaultNetworkService: NetworkService) {
      self.defaultNetworkService = defaultNetworkService
      self.persistentManager = persistentManager
  }
  
}

extension DefualtImageRepository: ImageRepository {

//
//  func resetRepository(completion: @escaping ((Error?) -> Void)) {
//    print("TBD")
//  }
  
  func fetchImages(endPoint: EndPoint,
                   completion: @escaping (Result<[Image], Error>) -> Void) {
    let request = RequsetComponent(endPoint: endPoint)

   self.fetchSavedImage { result in
     
     if case let .success(savedImageEntities) = result {
       let savedImageSets = Set(savedImageEntities.map({$0.toDomain()}))
       
       self.defaultNetworkService.request(on: request) {[weak self] result in
         switch result {
         case .success(let data):
           guard let decodedData = self?.decorder.decode(data: data) else {return}
           var images = decodedData.map({$0.toDomain()})
           for i in 0..<images.count {
             if savedImageSets.contains(images[i]) {
               images[i].changeLikeState(to: true)
             }
           }
           completion(.success(images))
         case .failure(let error):
           completion(.failure(error))
         }
       }
     }
    }
  }
  
  func fetchSavedImage(completion: @escaping (Result<[ImageEntity], Error>) -> Void) {
    persistentManager.fetchStoredImages(completion: completion)
  }

  func saveImage(_ image: Image, completion: @escaping (Result<Image, Error>) -> Void) {
    persistentManager.insertImage(image, completion: completion)
  }

  
  
  func deleteImage(_ image: Image, completion: @escaping ((Error?) -> Void)) {
//    ImageCacheManager.shared.deleteSavedImage(imageEntity: imageEntity) { error in
//      if let error = error {
//        completion(error)
//      }else {
//        completion(nil)
//      }
//    }
  }
  
//  func resetRepository(completion: @escaping ((Error?) -> Void)) {
//    ImageManager.shared.clearStorage(){ result in
//      if case let .failure(error) = result {
//        completion(error)
//      }
//    }
//  }
  
}
