//
//  ImageEntity.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct Image: Identifiable {
  let id: String
  let imageURL: URL
  private(set) var width: Float
  private(set) var height: Float
  private(set) var memo: String?
  private(set) var isLiked: Bool
  
  init(id:String, imageURL:URL, width: Float, height: Float, memo: String?, isliked: Bool) {
    self.id = id
    self.imageURL = imageURL
    self.width = width
    self.memo = memo
    self.height = height
    self.isLiked = isliked
  }

  mutating func changeLikeState(to state: Bool){
    self.isLiked = state
  }
  
  mutating func makeMemo(with memo: String?) {
    self.memo = memo
  }
}

extension Image: Hashable {
  
  static func ==(lhs: Image, rhs: Image) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
