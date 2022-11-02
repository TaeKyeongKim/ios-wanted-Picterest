//
//  SaveViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/29.
//

import Foundation

protocol SaveViewModelInput {
  func fetchImage()
  func didLikeImage(viewModel: ImageViewModel)
//  func viewWillDisappear()
}

protocol SaveViewModelOutput {
  var items: Observable<[ImageViewModel]> { get }
  var error: Observable<String> { get }
  subscript(index: IndexPath) -> Image? { get }
}


protocol SaveViewModel: SaveViewModelOutput,SaveViewModelInput {}

final class DefaultSaveViewModel {
  
  var items: Observable<[ImageViewModel]> = Observable([])
  var error: Observable<String> = Observable("")

  var didUpdateLikeStatusAt: ((Int) -> Void)?
  private var imageList: [Image] = []
  private let fetchImageUsecase: DefaultFetchImageUsecase
  private let likeImageUsecase: UpdateImageLikeStateUsecase
  
  init(fetchImageUsecase: DefaultFetchImageUsecase, likeImageUescase: UpdateImageLikeStateUsecase) {
    self.fetchImageUsecase = fetchImageUsecase
    self.likeImageUsecase = likeImageUescase
  }
  
  subscript(index: IndexPath) -> Image? {
    return imageList[index.row]
  }
  
  
  //MARK: 1.0 appendList(Image):
  private func appendList(images: [Image]) {
    var tempViewModel: [ImageViewModel] = []
    for value in images {
      imageList.append(value)
      tempViewModel.append(ImageViewModel(model: value, index: imageList.count))
    }
    items.value += tempViewModel
  }
  
  
  private func fetchSavedImages() {
    fetchImageUsecase.execute { result in
      switch result {
      case.success(let imageEntity):
        self.imageList = imageEntity.map({$0.toDomain()})
      case .failure(let error):
        self.error.value = NSLocalizedString("Fetching Error", comment: error.localizedDescription)
      }
    }
  }
  
 
  
//  func resetList() {
//    imageList.value.removeAll()
//  }
//
//  func updateLikeStatus() {
//    let storedModels = repository.fetchSavedImageData()
//    imageList.value.forEach({ imageEntity in
//      if storedModels.contains(where: {$0.id == imageEntity.id}) {
//        imageEntity.toogleLikeStates()
//      }
//    })
//  }
//
//  func resetLikeStatus() {
//    imageList.value.forEach({ imageEntity in
//      if imageEntity.isLiked == true {
//        imageEntity.toogleLikeStates()
//      }
//    })
//  }
//

//
//  func toogleLikeState(item entity: Image, completion: @escaping ((Error?) -> Void)) {
//    if entity.isLiked == true {
//      repository.deleteImage(imageEntity: entity){ error in
//        if let error = error {
//          completion(error)
//        }else {
//          guard let index = self.imageList.value.firstIndex (where: { $0.id == entity.id}) else {return}
//          self.imageList.value.remove(at: index)
//          completion(nil)
//        }
//      }
//    }
//  }
  
}

extension DefaultSaveViewModel: SaveViewModel {
  func didLikeImage(viewModel: ImageViewModel) {
    //
  }
  
  func fetchImage() {
    self.fetchSavedImages()
  }
  


}
