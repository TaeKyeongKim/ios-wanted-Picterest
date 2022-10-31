//
//  ImageEntity+CoreDataClass.swift
//  Picterest
//
//  Created by Kai Kim on 2022/10/31.
//
//

import Foundation
import CoreData

@objc(ImageEntity)
public class ImageEntity: NSManagedObject {
  func toDomain() -> Image {
    return .init(id: self.id,
                 imageURL: self.imageURL,
                 width: self.width,
                 height: self.height,
                 memo: self.memo,
                 isliked: self.isLiked)
  }
}

//let id: String
//let imageURL: URL
//private(set) var width: Float
//private(set) var height: Float
//private(set) var memo: String?
//private(set) var isLiked: Bool
