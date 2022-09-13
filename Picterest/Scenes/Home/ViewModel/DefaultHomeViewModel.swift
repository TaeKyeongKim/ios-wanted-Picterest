//
//  HomeViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

protocol HomeViewModelInput {
  func didLoadNextPage()
  func didLikeImage(id: String)
//  func viewWillAppear()
  func viewWillDisappear()
  
}

protocol HomeViewModelOutput {
  var items: Observable<[ImageViewModel]> { get }
  var error: Observable<String> { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {}

final class DefaultHomeViewModel: HomeViewModel {
  
  private var imageList: [Image] = []
  private let fetchImageUsecase: DefaultFetchImageUsecase
  private let likeImageUsecase: UpdateImageLikeStateUsecase
  private(set) var imagesPerPage = 15
  private var currentPage: Int {
    return self.imageList.count / imagesPerPage
  }
  
  var items: Observable<[ImageViewModel]> = Observable([])
  var error = Observable<String>("")
  
  init(fetchImageUsecase: DefaultFetchImageUsecase,
       likeImageUsecase: LikeImageUsecase) {
    self.fetchImageUsecase = fetchImageUsecase
    self.likeImageUsecase = likeImageUsecase
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
  
  //MARK: 2.0 updateList(
  //저장된것을 가져오는거랑 fetch 할때 캐싱에 되어 있던 DTO 를 가져오는건 다르지않나?
  //그럼 fetch 해올때 id 와 같은 image 가 있으면 Coredata 에서 가져오는게 맞지않을까? 라는 생각..
//  private func updateImageList(images: [Image]) {
//    var tempViewModel: [ImageViewModel] = []
//    images.forEach({ [weak self] image in
//      if !items.value.contains(where: {$0.id == image.id}) {
//        self?.imageList.append(image)
//        tempViewModel.append(ImageViewModel(model: image, index: imageList.count))
//      }
//    })
//    items.value += tempViewModel
//  }
  
  private func resetList() {
    imageList = []
    items.value = []
  }
  
//  private func updateLikeStatus() {
//    fetchImageUsecase.execute(cached: updateImageList)
//  }
  
  private func resetLikeStatus() {
    items.value.forEach({ imageEntity in
      if imageEntity.isLiked == true {
        imageEntity.toogleLikeStates()
      }
    })
  }
  
  private func fetchImages(_ request: FetchImageUsecaseRequestValue) {
    fetchImageUsecase.execute(requestValue: request,
                              completion: { [weak self] result in
      switch result {
      case .success(let newImages):
        self?.appendList(images: newImages)
      case .failure(let error):
        self?.error.value = error.localizedDescription
      }
    })
  }
  
  private func saveImage(item: Image, completion: @escaping ((Result<ImageViewModel,Error>) -> Void)) {
    likeImageUsecase.execute(on: item){ error in
      if let error = error {
        completion(.failure(error))
      }else {
        guard let imageViewModel = self.items.value.first(where: {$0.id == item.id}) else {return}
        imageViewModel.toogleLikeStates()
        completion(.success(imageViewModel))
      }
    }
  }
}



extension DefaultHomeViewModel {
  
//  func viewWillAppear() {
//    updateLikeStatus()
//  }
  
  func viewWillDisappear() {
    resetList()
  }
  
  func didLoadNextPage() {
    let request = FetchImageUsecaseRequestValue(page: currentPage+1)
    fetchImages(request)
  }
  
  func didLikeImage(id: String) {
    guard let modelIndex = imageList.firstIndex(where: {$0.id == id}) else {return}
    let item = imageList[modelIndex]
    saveImage(item: item) { result in
      switch result {
      case .success(let imageViewModel):
        item.changeLikeState(to: imageViewModel.isLiked)
      case .failure(let error):
        self.error.value = error.localizedDescription
      }
    }
  }
  
}
