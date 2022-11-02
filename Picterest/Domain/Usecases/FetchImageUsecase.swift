//
//  FetchImageUsecase.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/16.
//

import Foundation

protocol FetchImageUsecase {
  func execute(requestValue: FetchImageUsecaseRequestValue,
               completion: @escaping (Result<[Image],Error>) -> Void)
  func execute(comepletion: @escaping (Result<[ImageEntity], Error>) -> Void)
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
  
  func execute(requestValue: FetchImageUsecaseRequestValue,
               completion: @escaping (Result<[Image], Error>) -> Void) {
    
    let endPoint = EndPoint(path: .showList,
                            query: .imagesPerPage(pageNumber: requestValue.page,
                                                  perPage: requestValue.imagesPerPage))
    //TODO: repository
    return imageRepository.fetchImages(endPoint: endPoint,
                                       completion: completion)
  }
  
  
  func execute(comepletion: @escaping (Result<[ImageEntity], Error>) -> Void) {
    imageRepository.fetchSavedImage(completion: comepletion)
  }
}
