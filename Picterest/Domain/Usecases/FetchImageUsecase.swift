//
//  FetchImageUsecase.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/16.
//

import Foundation

protocol FetchImageUsecase {
  func execute(requestValue: FetchImageUsecaseRequestValue,
               completion: @escaping (Result<[Image],NetworkError>) -> Void)
  func execute(cached: @escaping ([Image]) -> Void)
}

struct FetchImageUsecaseRequestValue {
  let page: Int
  let imagesPerPage: Int = 15
}

final class DefaultFetchImageUsecase: FetchImageUsecase {
  
  private let imageRepository: ImageRepository
  
  init(imageRespository: ImageRepository) {
    self.imageRepository = imageRespository
  }
  
  //TODO: Consider cached data as ImageEntity. Not only Image itself.
  func execute(requestValue: FetchImageUsecaseRequestValue,
               completion: @escaping (Result<[Image], NetworkError>) -> Void) {
    
    let endPoint = EndPoint(path: .showList,
                            query: .imagesPerPage(pageNumber: requestValue.page,
                                                  perPage: requestValue.imagesPerPage))
    //TODO: repository
    return imageRepository.fetchImages(endPoint: endPoint,
                                       completion: { result in
      completion(result)
    })
  }
  
  func execute(cached: @escaping ([Image]) -> Void) {
    return imageRepository.fetchSavedImage(cached: cached)
  }
  
}


