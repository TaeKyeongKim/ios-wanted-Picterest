//
//  ImageViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/24.
//

import Foundation

final class ImageViewModel: Identifiable {
  
  let id: String
  let imageURL: URL
  private(set) var width: Float?
  private(set) var height: Float?
  private(set) var isLiked: Bool
  private(set) var memo: String?
  private(set) var imageData: Data?
  
  init(id:String, imageURL:URL, isLiked: Bool, width: Float, height: Float) {
    self.id = id
    self.isLiked = isLiked
    self.imageURL = imageURL
    self.width = width
    self.height = height
  }
  
  init(id:String, imageURL:URL, isLiked: Bool, memo: String) {
    self.id = id
    self.isLiked = isLiked
    self.imageURL = imageURL
    self.memo = memo
  }
  
}

extension ImageEntity {
  
  func toogleLikeStates() {
    self.isLiked = !isLiked
  }
  
  func configureMemo(memo: String) {
    self.memo = memo
  }
  
  func saveImage(image:UIImage) {
    self.image = image
  }

}
