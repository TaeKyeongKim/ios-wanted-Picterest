//
//  ImageData+CoreDataClass.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/28.
//
//

import Foundation
import CoreData

@objc(ImageEntity)
public class ImageEntity: NSManagedObject {
  @NSManaged public var id: String
  @NSManaged public var memo: String?
  @NSManaged public var imageURL: URL
  @NSManaged public var isLiked: Bool
  @NSManaged public var width: Float
  @NSManaged public var height: Float
}
