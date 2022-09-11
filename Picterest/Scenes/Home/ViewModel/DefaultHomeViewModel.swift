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
  func viewWillAppear()
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
  //사용자가 스크롤을 하고 새로운 데이터가 fetching 되어 올때, `appendList(Image)` 함수는 새로운 데이터가 이미
  //저장되어있는 데이터인지 확인하는 로직을 가지고 있다. 이미 저장된 데이터가 있다면, 그 데이터의 `isLiked` 상태를 `true` 로 바꾸어서 `ViewModel` 을 생성해준다.
  private func appendList(images: [Image]) {
    var tempViewModel: [ImageViewModel] = []
    for value in images {
      if items.value.contains(where: {$0.id == value.id}) {continue}
      imageList.append(value)
      tempViewModel.append(ImageViewModel(model: value, index: imageList.count))
    }
    items.value += tempViewModel
  }
  
  //MARK: 2.0 updateList(
  //사용자가 `Save` 화면에서 어떤 이미지를 삭제 하고 `Home` 화면으로 전환할때 `updateList(Image)` 는 저장된 이미지의 `isliked` 상태를 확인하고 해당 `ImageViewModel` 의 상태를 바꾸어준다.
  //아 어떻게 해주지..
  //이 함수의 매개변수로 전해져오는 images 의 값들은 core data 에 저장되어있는 이미지 데이터들임
  //반대로 여기에 없다면 저장해제가 되었다는 뜻이다.
  private func updateImageList(images: [Image]) {
    items.value.forEach({ imageViewModel in
      if images.contains(where: {$0.id != imageViewModel.id}) {
        imageViewModel.toogleLikeStates()
      }
    })
  }
  
  private func resetList() {
    imageList = []
    items.value = []
  }
  
  private func updateLikeStatus() {
    fetchImageUsecase.execute(cached: updateImageList)
  }
  
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
  
  private func saveImage(item: Image, completion: @escaping ((Error?) -> Void)) {
    likeImageUsecase.execute(on: item){ error in
      if let error = error {
        completion(error)
      }else {
        for imageViewModel in self.items.value {
          if imageViewModel.id == item.id {
            imageViewModel.toogleLikeStates()
          }
        }
        completion(nil)
      }
    }
  }
  
}

extension DefaultHomeViewModel {
  
  func viewWillAppear() {
    updateLikeStatus()
  }
  
  func viewWillDisappear() {
    resetList()
  }
  
  func didLoadNextPage() {
    let request = FetchImageUsecaseRequestValue(page: currentPage+1)
    fetchImages(request)
  }
  
  func didLikeImage(id: String) {
    guard let model = imageList.firstIndex(where: {$0.id == id}) else {return}
    saveImage(item: imageList[model]) { error in
      if let error = error {
        self.error.value = error.localizedDescription
      }
    }
  }
  
}
