//
//  HomeViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

protocol HomeViewModelInput {
  func fetchData()
  func didLoadNextPage()
  func didLikeImage(itemIndex: IndexPath, memo: String?, completion: @escaping (Result<Void,Error>) -> Void)
  func searchImageViewModel(on: Image) -> ImageViewModel?
  func refreshData(completion: @escaping ([Int]) -> Void)
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
  private let fetchImageUsecase: FetchImageUsecase
  private let likeImageUsecase: LikeImageUsecase
  let imagesPerPage: Int
  private var currentPage: Int {
    return self.imageList.count / imagesPerPage
  }
  
  var items: Observable<[ImageViewModel]> = Observable([])
  var error = Observable<String>("")
  
  init(fetchImageUsecase: FetchImageUsecase,
       likeImageUsecase: LikeImageUsecase,
       imagesPerPage: Int) {
    self.fetchImageUsecase = fetchImageUsecase
    self.likeImageUsecase = likeImageUsecase
    self.imagesPerPage = imagesPerPage
  }
  

  private func appendList(images: [Image]) {
    var tempViewModel: [ImageViewModel] = []
    for image in images {
      imageList.append(image)
      tempViewModel.append(ImageViewModel(model: image, index: imageList.count))
    }
    items.value += tempViewModel
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
  
  private func refreshLists(completion: @escaping ([Int]) -> Void) {
    fetchImageUsecase.execute { [weak self] result in
      guard let self = self else {return}
      var deletedIndex: [Int] = []
      switch result {
      case .success(let images):
        let imageSets = Set(images)
        for i in 0..<self.imageList.count{
          if !imageSets.contains(self.imageList[i]) {
            deletedIndex.append(i)
            self.imageList[i].changeLikeState(to: false)
            self.items.value[i].changeLikeState(to: false)
          }
        }
        completion(deletedIndex)
      case .failure(let error):
        self.error.value = error.localizedDescription
      }
    }
  }
  
  
  private func saveImage(newImage: Image, memo: String?, completion: @escaping (Result<Void,Error>) -> Void) {
    likeImageUsecase.execute(on: newImage) { [unowned self] result in
        switch result {
        case .success(_):
          guard let imageViewModel = searchImageViewModel(on: newImage), let imageIndex = imageList.firstIndex(of: newImage) else {return}
          imageList[imageIndex].changeLikeState(to: true)
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

  func fetchData() {
    fetchImages(FetchImageUsecaseRequestValue(page: 0, imagesPerPage: imagesPerPage))
  }
  
  func didLoadNextPage() {
    let request = FetchImageUsecaseRequestValue(page: currentPage+1, imagesPerPage: imagesPerPage)
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
 
  func refreshData(completion: @escaping ([Int]) -> Void) {
    refreshLists(completion: completion)
  }

}
