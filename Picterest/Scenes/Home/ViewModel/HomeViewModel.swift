//
//  HomeViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

protocol HomeViewModelInput {
  func fetchData()
  func didLoadNextPage()
  func didLikeImage(itemIndex: IndexPath, memo: String?, completion: @escaping (Result<Void,Error>) -> Void)
  func viewWillDisappear()
  func searchImageViewModel(on: Image) -> ImageViewModel?
}

protocol HomeViewModelOutput {
  var items: Observable<[ImageViewModel]> { get }
  var error: Observable<String> { get }
  var imagesPerPage: Int { get }
  subscript(index: IndexPath) -> Image { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {}

final class DefaultHomeViewModel: HomeViewModel {
  
  private var imageList: [Image] = []
  private let fetchImageUsecase: DefaultFetchImageUsecase
  private let likeImageUsecase: UpdateImageLikeStateUsecase
  let imagesPerPage = 15
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
  

  
  //MARK: 1.0 appendList(Image):
  private func appendList(images: [Image]) {
    var tempViewModel: [ImageViewModel] = []
    for image in images {
      imageList.append(image)
//      items.value.updateValue(ImageViewModel(model: image, index: imageList.count), forKey: image)
      tempViewModel.append(ImageViewModel(model: image, index: imageList.count))
    }
    items.value += tempViewModel
//    (imageList.map({[$0:ImageViewModel(model: $0, index: "d")]}))
  }

//  private func resetList() {
//    imageList = []
//    items.value = []
//  }
  

  
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
  
  private func saveImage(newImage: Image, memo: String?, completion: @escaping (Result<Void,Error>) -> Void) {
  
    likeImageUsecase.execute(on: newImage) { [unowned self] result in
        switch result {
        case .success(_):
          guard let imageViewModel = searchImageViewModel(on: newImage) else {return}
          imageViewModel.changeLikeState(to: newImage.isLiked)
          completion(.success(()))
        case .failure(let error):
          self.error.value = error.localizedDescription
          completion(.failure(error))
        }
      }
  }
  
 
}



extension DefaultHomeViewModel {
  
  subscript(index: IndexPath) -> Image {
    return imageList[index.row]
  }
  
  func viewWillDisappear() {
//    resetList()
  }
  
  func fetchData() {
    fetchImages(FetchImageUsecaseRequestValue(page: 0))
  }
  
  func didLoadNextPage() {
    let request = FetchImageUsecaseRequestValue(page: currentPage+1)
    fetchImages(request)
  }
  
  func didLikeImage(itemIndex: IndexPath, memo: String?,completion: @escaping (Result<Void,Error>) -> Void) {
    var newImage = imageList[itemIndex.item] //got width, height, like state = false
    newImage.changeLikeState(to: true)
    newImage.makeMemo(with: memo)
    saveImage(newImage: newImage, memo: memo, completion: completion)
  }
  
  func searchImageViewModel(on image: Image) -> ImageViewModel? {
   return self.items.value.first(where:{$0.id == image.id})
 }
  
}
