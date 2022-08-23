//
//  ImageEntity.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

final class ImageEntity: Identifiable {
  let id: String
  let imageURL: URL
  private(set) var width: CGFloat?
  private(set) var height: CGFloat?
  private(set) var isLiked: Bool
  private(set) var memo: String?
  private(set) var image: UIImage?
//  private(set) var storedDirectory: URL?
  
  init(id:String, imageURL:URL, isLiked: Bool, width: CGFloat, height: CGFloat) {
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
//    self.storedDirectory = storedDirectory
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
  
//  func saveStoredDirectory(url: URL) {
//    print("Saving New URL to = \(url)")
//    self.storedDirectory = url
//  }
  
}
