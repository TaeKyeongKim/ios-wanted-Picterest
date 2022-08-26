//
//  HomeViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit


final class HomeViewModel {
  
  var didUpdateLikeStatusAt: ((Int) -> Void)?
  private var imageList: [Image] = []
  private let fetchImageUsecase: DefaultFetchImageUsecase
  private let likeImageUsecase: ChangeImageLikeStateUsecase
  //  private let likeImageRepository
  private(set) var imagesPerPage = 15
  private var currentPage: Int {
    return self.imageList.count / imagesPerPage
  }
  
  var items: Observable<[ImageViewModel]> = Observable([])
  
  init(fetchImageUsecase: DefaultFetchImageUsecase,
       likeImageUsecase: LikeImageUsecase) {
    self.fetchImageUsecase = fetchImageUsecase
    self.likeImageUsecase = likeImageUsecase
  }
  
  subscript(index: IndexPath) -> Image? {
    return imageList[index.row]
  }
  
  private func appendList(_ newImages: [Image]) {
    print("현재 페이지는 = \(currentPage) 입니다")
    imageList += newImages
    for (index, value) in imageList.enumerated() {
      items.value.append(ImageViewModel(model: value, index: index))
    }
  }
  
  func resetList() {
    imageList = []
    items.value = []
  }
  
  
  
  func updateLikeStatus() {
    let storedModels = fetchImageUsecase.fetchSavedImageData()
    items.value.forEach({ imageEntity in
      if storedModels.contains(where: {$0.id == imageEntity.id}) {
        imageEntity.toogleLikeStates()
      }
    })
  }
  
  func resetLikeStatus() {
    items.value.forEach({ imageEntity in
      if imageEntity.isLiked == true {
        imageEntity.toogleLikeStates()
      }
    })
  }
  
  func fetchImages() {
    let requestValue = FetchImageUsecaseRequestValue(page: currentPage + 1)
    //let storedModels = repository.fetchSavedImageData() //새로 패치해온 이미지가 이미 저장되어 있는 이미지인지 체크 하려고 저장되어 있는 이미지 fetch 한다. 
//    let endPoint = EndPoint(path: .showList, query: .imagesPerPage(pageNumber: page, perPage: imagesPerPage))
    fetchImageUsecase.execute(requestValue: requestValue, completion: { [weak self] result in
      switch result {
      case .success(let newImages):
        self?.appendList(newImages)
      case .failure(let error):
        print(error)
      }
    })
    
  
    
//    (endPoint: endPoint) { result in
//      switch result {
//      case .success(let data):
//        for item in data {
//          if storedModels.contains(where: {$0.id == item.id}) {
//            item.toogleLikeStates()
//          }
//        }
//        self.imageList.value += data
//      case .failure(let error):
//        print(error)
//      }
//    }
  }
  
//  func toogleLikeState(item entity: Image, completion: @escaping ((Error?) -> Void)) {
//    entity.toogleLikeStates()
//    repository.saveImage(imageEntity: entity){ error in
//      if let error = error {
//        completion(error)
//      }else {
//        completion(nil)
//      }
//    }
//  }
  
}

private extension HomeViewModel {
//  func pageCount() -> Int {
//    return self.items.value.count / imagesPerPage
//  }
}
