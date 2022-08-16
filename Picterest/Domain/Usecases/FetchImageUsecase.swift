//
//  FetchImageUsecase.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/16.
//

import Foundation

protocol FetchImageUsecase {
  func execute(requestValue: FetchImageUsecaseRequestValue,
               cached: @escaping ([ImageEntity]) -> Void,
               completion: @escaping (Result<[ImageEntity],NetworkError>) -> Void)
}

struct FetchImageUsecaseRequestValue {
  let page: Int
  let imagesPerPage: Int
}

final class DefaultFetchImageUsecase: FetchImageUsecase {
  
  private let imageRepository: HomeRepository
  
  init(imageRespository: HomeRepository) {
    self.imageRepository = imageRespository
  }
  
  //TODO: Consider cached data as ImageEntity. Not only Image itself.
  func execute(requestValue: FetchImageUsecaseRequestValue,
               cached: @escaping ([ImageEntity]) -> Void,
               completion: @escaping (Result<[ImageEntity], NetworkError>) -> Void) {
    
    let endPoint = EndPoint(path: .showList,
                            query: .imagesPerPage(pageNumber: requestValue.page,
                                                  perPage: requestValue.imagesPerPage))
    //TODO: repository
    return imageRepository.fetchImages(endPoint: endPoint) { result in
      completion(result)
    }
    
  }
  
  
}


