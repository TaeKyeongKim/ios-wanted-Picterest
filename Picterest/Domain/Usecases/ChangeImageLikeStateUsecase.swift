//
//  SaveImageUsecase.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/16.
//

import Foundation

protocol ChangeImageLikeStateUsecase {
  func execute(item: ImageEntity, completion: @escaping ((Error?)-> Void))
}


final class LikeImageUsecase: ChangeImageLikeStateUsecase {
  
  private var repository: ImageRepository
  
  init (repository: ImageRepository){
    self.repository = repository
  }
  
  func execute(item: ImageEntity, completion: @escaping ((Error?) -> Void)) {
    item.toogleLikeStates()
    repository.saveImage(imageEntity: item){ error in
      if let error = error {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }
  
}

final class UndoLikeImageUsecase: ChangeImageLikeStateUsecase {
  
  private var repository: HomeRepository
  
  init (repository: HomeRepository){
    self.repository = repository
  }
  
  func execute(item: ImageEntity, completion: @escaping ((Error?) -> Void)) {
    repository.deleteImage(imageEntity: item) { error in
      if let error = error {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }
  
}

