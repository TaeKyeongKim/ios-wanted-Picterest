//
//  SaveImageUsecase.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/16.
//

import Foundation

protocol UpdateImageLikeStateUsecase {
  func execute(on item: Image, completion: @escaping ((Error?)-> Void))
}


final class LikeImageUsecase: UpdateImageLikeStateUsecase {
  
  private var repository: ImageRepository
  
  init (repository: ImageRepository){
    self.repository = repository
  }
  
  func execute(on item: Image, completion: @escaping ((Error?) -> Void)) {
    repository.saveImage(imageEntity: item) { error in
      if let error = error {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }
  
}

final class UndoLikeImageUsecase: UpdateImageLikeStateUsecase {
  
  private var repository: ImageRepository
  
  init (repository: ImageRepository){
    self.repository = repository
  }
  
  func execute(on item: Image, completion: @escaping ((Error?) -> Void)) {
    repository.deleteImage(imageEntity: item) { error in
      if let error = error {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }
  
}

