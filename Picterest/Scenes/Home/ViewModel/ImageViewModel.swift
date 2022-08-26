//
//  ImageViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/24.
//

import Foundation

final class ImageViewModel: Identifiable {
  
//  let id: String
//  let imageURL: URL
//  private(set) var width: Float
//  private(set) var height: Float
  private(set) var memo: String
  private(set) var isLiked: Bool
  private(set) var imageData: Data?

  //I've gotta keep track on the isLiked Status --> Upon user's interaction on changing like state,
  //this particular entity
  //I just have to show if the image is liked or not -> so there will be no isliked status in Image Entity
  //Image Entity will only consist of DTO data

  init (model: Image, index: Int) {
    self.isLiked = model.isLiked
    self.memo = model.memo ?? "\(index + 1) 번째 사진"
  }
}

extension ImageViewModel {
  
  func toogleLikeStates() {
    self.isLiked = !isLiked
  }
  
  func setMemo(memo: String) {
    self.memo = memo
  }
  
  func saveImageData(imageData: Data) {
    self.imageData = imageData
  }
}

//extension ImageViewModel: Equatable {
//    static func == (lhs: ImageViewModel, rhs: ImageViewModel) -> Bool {
//        return lhs.query == rhs.query
//    }
//}
