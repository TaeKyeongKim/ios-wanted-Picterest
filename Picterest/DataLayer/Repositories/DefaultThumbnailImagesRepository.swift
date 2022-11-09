//
//  DefaultThumnailImagesRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/08.
//

import Foundation

final class DefualtThumbnailImagesRepository: ThumbnailImagesRepository {
  
  private let imageDataNetworkService: NetworkService
  
  init(imageDataNetworkService: NetworkService) {
    self.imageDataNetworkService = imageDataNetworkService
  }
  
  func fetchImageData(with imageURL: URL, completion: @escaping (Result<Data, Error>) -> Void) {

    imageDataNetworkService.request(on: imageURL) { result in
      let result = result.mapError({$0 as Error})
      completion(result)
    }
  }
  
  
}
