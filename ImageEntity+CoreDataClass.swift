//
//  ImageEntity+CoreDataClass.swift
//  Picterest
//
//  Created by Kai Kim on 2022/10/31.
//
//

import CoreData

@objc(ImageEntity)
public class ImageEntity: NSManagedObject {
  
}

extension ImageEntity {
  func toDomain() -> Image {
    return .init(id: id,
                 imageURL: imageURL,
                 width: width,
                 height: height,
                 memo: memo,
                 isliked: isLiked)
  }
}
