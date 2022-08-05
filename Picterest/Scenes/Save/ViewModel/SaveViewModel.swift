//
//  SaveViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/29.
//

import Foundation

final class SaveViewModel: ImageConfigurable {

  var didUpdateLikeStatusAt: ((Int) -> Void)?
  var imageList: Observable<[ImageEntity]> = Observable([])
  let repository = HomeRepository()

  subscript(index: IndexPath) -> ImageEntity? {
    return imageList.value[index.row]
  }
  
  func resetList() {
    imageList.value.removeAll()
  }
  
  func updateLikeStatus() {
    let storedModels = repository.fetchSavedImageData()
    imageList.value.forEach({ imageEntity in
      if storedModels.contains(where: {$0.id == imageEntity.id}) {
        imageEntity.toogleLikeStates()
      }
    })
  }
  
  func resetLikeStatus() {
    imageList.value.forEach({ imageEntity in
      if imageEntity.isLiked == true {
        imageEntity.toogleLikeStates()
      }
    })
  }
  
  func fetchImages() {
    let data = repository.fetchSavedImageData()
    var tempList: [ImageEntity] = []
    data.forEach({
      guard let imageEntity = $0.toDomain() else {return}
      tempList.append(imageEntity)
    })
    imageList.value = tempList
  }
  
  func toogleLikeState(item entity: ImageEntity, completion: @escaping ((Error?) -> Void)) {
    if entity.isLiked == true {
      repository.deleteImage(imageEntity: entity){ error in
        if let error = error {
          completion(error)
        }else {
          guard let index = self.imageList.value.firstIndex (where: { $0.id == entity.id}) else {return}
          self.imageList.value.remove(at: index)
          completion(nil)
        }
      }
    }
  }
  
}
