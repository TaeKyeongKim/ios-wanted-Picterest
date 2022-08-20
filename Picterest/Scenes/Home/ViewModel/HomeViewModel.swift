//
//  HomeViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

final class HomeViewModel: ImageConfigurable {
  
  var didUpdateLikeStatusAt: ((Int) -> Void)?
  var imageList: Observable<[ImageEntity]> = Observable([])
  let repository = HomeRepository()
  private(set) var imagesPerPage = 15
  
  subscript(index: IndexPath) -> ImageEntity? {
    return imageList.value[index.row]
  }
  
  func resetList() {
    imageList.value = []
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
    let page = pageCount() + 1
    let storedModels = repository.fetchSavedImageData()
    let endPoint = EndPoint(path: .showList, query: .imagesPerPage(pageNumber: page, perPage: imagesPerPage))
    
    repository.fetchImages(endPoint: endPoint) { result in
      switch result {
      case .success(let data):
        for item in data {
          if storedModels.contains(where: {$0.id == item.id}) {
            item.toogleLikeStates()
          }
        }
        self.imageList.value += data
      case .failure(let error):
        print(error)
      }
    }
  }
  
  func toogleLikeState(item entity: ImageEntity, completion: @escaping ((Error?) -> Void)) {
    entity.toogleLikeStates()
    repository.saveImage(imageEntity: entity){ error in
      if let error = error {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

}

private extension HomeViewModel {
  func pageCount() -> Int {
    return self.imageList.value.count / imagesPerPage
  }
}
