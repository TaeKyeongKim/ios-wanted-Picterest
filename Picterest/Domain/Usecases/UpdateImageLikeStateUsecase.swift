//
//  SaveImageUsecase.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/16.
//

import Foundation

protocol UpdateImageLikeStateUsecase {
  func execute(on image: Image, completion: @escaping (Result<Image, Error>) -> Void)
}


final class LikeImageUsecase: UpdateImageLikeStateUsecase {
  
  private var repository: ImageRepository
  
  init (repository: ImageRepository){
    self.repository = repository
  }
  
  func execute(on image: Image, completion: @escaping (Result<Image, Error>) -> Void) {
    repository.saveImage(image, completion: completion)
  }
  
}

final class UndoLikeImageUsecase: UpdateImageLikeStateUsecase {
  
  private var repository: ImageRepository
  
  init (repository: ImageRepository){
    self.repository = repository
  }
  
  func execute(on image: Image, completion: @escaping (Result<Image, Error>) -> Void) {
//    repository.deleteImage(image) { error in
//      if let error = error {
//        completion(error)
//      }else {
//        completion(nil)
//      }
//    }
  }
  
}

