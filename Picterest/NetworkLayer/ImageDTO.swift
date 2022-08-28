//
//  ImageDTO.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct ImageDTO: Decodable {
  let id: String
  let width: Int
  let height: Int
  let imageURL: ImageURL
  enum CodingKeys: String, CodingKey {
      case id, width, height
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
  
  func toDomain() -> Image {
    return .init(id: self.id,
                 imageURL: self.imageURL.url,
                 width: Float(self.width),
                 height: Float(self.height),
                 memo: nil,
                 isliked: false)
  }
  
}
