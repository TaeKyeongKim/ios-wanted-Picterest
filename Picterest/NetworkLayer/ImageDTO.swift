//
//  ImageDTO.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct ImageDTO: Decodable {
  let id: String
  let imageURL: ImageURL
  enum CodingKeys: String, CodingKey {
      case id
      case imageURL = "urls"
  }
}

struct ImageURL: Decodable {
  let url: URL
  enum CodingKeys: String, CodingKey {
      case url = "regular"
  }
}

extension ImageDTO {
  
  func toDomain(index: Int) -> ImageEntity {
    return ImageEntity(id: self.id,
                       imageURL: self.imageURL.url,
                       memo: "\(index)번째 사진",
                       isLiked: false)
  }
  
}
