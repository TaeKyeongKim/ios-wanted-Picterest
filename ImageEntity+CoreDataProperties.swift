//
//  ImageEntity+CoreDataProperties.swift
//  Picterest
//
//  Created by Kai Kim on 2022/10/31.
//
//

import Foundation
import CoreData


extension ImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }
  
    @NSManaged public var height: Float
    @NSManaged public var id: String
    @NSManaged public var imageURL: URL
    @NSManaged public var isLiked: Bool
    @NSManaged public var memo: String?
    @NSManaged public var width: Float

}

extension ImageEntity : Identifiable {

}
