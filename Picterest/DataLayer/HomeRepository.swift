//
//  HomeRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct HomeRepository {
  
  func fetchImages(endPoint: EndPoint, completion: @escaping (Result<[Image], NetworkError>) -> Void) {
    let request = Requset(requestType: .get, body: nil, endPoint: endPoint)
    NetworkService.request(on: request.value) { result in
      switch result {
      case .success(let data):
        let decorder = Decoder<[ImageDTO]>()
        var tempList:[Image] = []
        guard let decodedData = decorder.decode(data: data) else {return}
        for item in decodedData {
          let imageEntity = item.toDomain()
          tempList.append(imageEntity)
        }
        completion(.success(tempList))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func fetchSavedImageData() -> [ImageData] {
    return ImageManager.shared.loadSavedImage()
  }
  
  
  func saveImage(imageEntity: Image, completion: @escaping ((Error?) -> Void)) {
    ImageManager.shared.saveImage(imageEntity){ error in
      if let error = error {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }
  
  func deleteImage(imageEntity: Image, completion: @escaping ((Error?) -> Void)) {
    ImageManager.shared.deleteSavedImage(imageEntity: imageEntity) { error in
      if let error = error {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }
  
  func resetRepository(completion: @escaping ((Error?) -> Void)) {
    ImageManager.shared.clearStorage(){ result in
      if case let .failure(error) = result {
        completion(error)
      }
    }
  }
  
}
