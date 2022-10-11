//
//  HomeRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

//Infrastructure layer has to be reconstructed. 
final class DefualtImageRepository {

  private let dataTransferService: DataTransferService
  private let cache: ImageStorage

  init(cache: ImageStorage, dataTransferService: DataTransferService = NetworkService()) {
      self.dataTransferService = dataTransferService
      self.cache = cache
  }
}

extension DefualtImageRepository: ImageRepository {
  
  func resetRepository(completion: @escaping ((Error?) -> Void)) {
    print("TBD")
  }
  
  
  func fetchImages(endPoint: EndPoint,
                   completion: @escaping (Result<[Image], NetworkError>) -> Void) {
    
    let savedImages = cache.fetchStoredImages()
    let decorder = Decoder<[ImageDTO]>()
    
    let request = Requset(requestType: .get, body: nil, endPoint: endPoint)
    dataTransferService.request(on: request.value) { result in
      switch result {
      case .success(let data):
        guard let decodedData = decorder.decode(data: data) else {return}
        let imageList = decodedData.map({$0.toDomain()})
        for savedImage in savedImages {
          if let matchedIndex = imageList.firstIndex(where: {$0.id == savedImage.id}) {
            imageList[matchedIndex].changeLikeState(to: savedImage.isLiked)
          }
        }
        completion(.success(imageList))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func fetchSavedImage(cached: @escaping ([Image]) -> Void) {
//    cached(ImageCacheManager.shared.loadSavedImage())
  }
    
  func saveImage(imageEntity: Image, completion: @escaping ((Error?) -> Void)) {
//    ImageCacheManager.shared.saveImage(imageEntity){ error in
//      if let error = error {
//        completion(error)
//      }else {
//        completion(nil)
//      }
//    }
  }
  
  func deleteImage(imageEntity: Image, completion: @escaping ((Error?) -> Void)) {
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
