//
//  SaveViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/29.
//

import Foundation

protocol SaveViewModelInput {
  func fetchImage()
  func didUnLikeImage(_ image: Image ,completion: @escaping (Error?) -> Void)
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
  private let fetchImageUsecase: FetchImageUsecase
  private let undolikeImageUsecase: UndoLikeImageUsecase
  
  init(fetchImageUsecase: FetchImageUsecase, undolikeImageUescase: UndoLikeImageUsecase) {
    self.fetchImageUsecase = fetchImageUsecase
    self.undolikeImageUsecase = undolikeImageUescase
  }
  
  subscript(index: IndexPath) -> Image? {
    return imageList[index.row]
  }
  
  
  private func appendList(images: [Image]) {
    var tempViewModel: [ImageViewModel] = []
    for image in images {
      if !imageList.contains(image){
        imageList.append(image)
        tempViewModel.append(ImageViewModel(model: image, index: imageList.count))
      }
    }
    items.value += tempViewModel
  }
  
  
  private func fetchSavedImages() {
    fetchImageUsecase.execute { [weak self] result in
      switch result {
      case.success(let imageEntity):
        self?.appendList(images: imageEntity)
      case .failure(let error):
        self?.error.value = NSLocalizedString("Fetching Error", comment: error.localizedDescription)
      }
    }
  }

  func unLikeImage(item model: Image, completion: @escaping ((Error?) -> Void)) {
    undolikeImageUsecase.execute(on: model) { [weak self] result in
      switch result {
      case .success(let deletedImage):
        guard let index = self?.imageList.firstIndex (where: { $0 == deletedImage}) else {return}
        self?.imageList.remove(at: index)
        self?.items.value.remove(at: index)
      case .failure(let error):
        self?.error.value = error.localizedDescription
        completion(error)
      }
    }
  }
  
}

extension DefaultSaveViewModel: SaveViewModel {

  func fetchImage() {
    self.fetchSavedImages()
  }
  
  func didUnLikeImage(_ image: Image, completion: @escaping (Error?) -> Void) {
    self.unLikeImage(item: image, completion: completion)
  }
}
