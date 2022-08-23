//
//  ImageData+CoreDataClass.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/28.
//
//

import Foundation
import CoreData

@objc(ImageData)
public class ImageData: NSManagedObject {
  @NSManaged public var id: String
  @NSManaged public var memo: String?
  @NSManaged public var imageURL: URL
}
