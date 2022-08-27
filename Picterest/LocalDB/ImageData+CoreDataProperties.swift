//
//  ImageData+CoreDataProperties.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/28.
//
//

import Foundation
import CoreData

extension ImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }

}

extension ImageEntity : Identifiable {
  
  func toDomain() -> Image? {
    return .init(id: self.id,
                 imageURL: self.imageURL,
                 width: self.width,
                 height: self.height,
                 memo: self.memo,
                 isliked: self.isLiked)
  }
  
}
