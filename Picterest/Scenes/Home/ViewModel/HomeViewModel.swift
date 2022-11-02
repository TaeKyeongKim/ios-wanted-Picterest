//
//  HomeViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

protocol HomeViewModelInput {
  func didLoadNextPage()
  func didLikeImage(imageViewModel: ImageViewModel)
  func viewWillDisappear()
}

protocol HomeViewModelOutput {
  var items: Observable<[ImageViewModel]> { get }
  var error: Observable<String> { get }
  subscript(index: IndexPath) -> Image? { get }
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

  private func resetList() {
    imageList = []
    items.value = []
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
  
  private func saveImage(viewModel: ImageViewModel) {
    guard let imageModelIndex = imageList.firstIndex(where: {$0.id == viewModel.id})else {return}
    let imageModel = imageList[imageModelIndex]
    likeImageUsecase.execute(on: imageModel) { result in
        switch result {
        case .success(var image):
          image.changeLikeState(to: true) //I have to check wheather the image status within the ImageList changed..
          viewModel.update(model: image)
        case .failure(let error):
          self.error.value = error.localizedDescription
        }
      }
      
//      if let error = error {
//        completion(.failure(error))
//      }else {
//        guard let imageViewModel = self.items.value.first(where: {$0.id == item.id}) else {return}
//        imageViewModel.toogleLikeStates()
//        completion(.success(imageViewModel))
//      }
//    }
  }
}



extension DefaultHomeViewModel {
  
  func viewWillDisappear() {
    resetList()
  }
  
  func didLoadNextPage() {
    let request = FetchImageUsecaseRequestValue(page: currentPage+1)
    fetchImages(request)
  }
  
  func didLikeImage(imageViewModel: ImageViewModel) {
    saveImage(viewModel: imageViewModel)
  }
  
}
