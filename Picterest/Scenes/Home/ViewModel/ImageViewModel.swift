//
//  ImageViewModel.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/24.
//

import UIKit

final class ImageViewModel: Identifiable {
  
  let id: String
  let imageURL: URL
  private(set) var memo: String
  private(set) var isLiked: Bool
  
  init (model: Image, index: Int) {
    self.id = model.id
    self.imageURL = model.imageURL
    self.isLiked = model.isLiked
    self.memo = model.memo ?? "\(index) 번째 사진"
  }
}

extension ImageViewModel {
  
  func update(model: Image) {
    self.isLiked = model.isLiked
    self.memo = model.memo ?? "\(String(describing: index)) 번째 사진"
  }

}


