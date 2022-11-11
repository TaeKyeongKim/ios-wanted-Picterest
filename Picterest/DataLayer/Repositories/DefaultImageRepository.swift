//
//  HomeRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

final class DefualtImageRepository {

  private let defaultNetworkService: NetworkService
  private let persistenStorage: ImagePersistentStorage
  private let decorder = Decoder<[ImageDTO]>()
  
  init(persistenStorage: ImagePersistentStorage, defaultNetworkService: NetworkService) {
      self.defaultNetworkService = defaultNetworkService
      self.persistenStorage = persistenStorage
  }
  
}

extension DefualtImageRepository: ImageRepository {


  func fetchImages(endPoint: EndPoint,
                   completion: @escaping (Result<[Image], Error>) -> Void) {
    let request = RequsetComponent(endPoint: endPoint)

   self.fetchSavedImage { [weak self] result in
     
     if case let .success(savedImageEntities) = result {
       let savedImageSets = Set(savedImageEntities)
       self?.defaultNetworkService.request(on: request) {  result in
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
  
  func fetchSavedImage(completion: @escaping (Result<[Image], Error>) -> Void) {
    persistenStorage.fetchStoredImages(completion: completion)
  }

  func saveImage(_ image: Image, completion: @escaping (Result<Image, Error>) -> Void) {
    persistenStorage.insertImage(image, completion: completion)
  }


  func deleteImage(_ image: Image, completion: @escaping (Result<Image,Error>) -> Void) {
    persistenStorage.delete(image, completion: completion)
  }
  
}
