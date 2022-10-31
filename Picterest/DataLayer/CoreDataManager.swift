//
//  CoreDataManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation
import CoreData

protocol ImageStorage {
  func fetchStoredImages() -> [ImageEntity]
//  func saveImage() -> 
}

final class CoreDataManager: ImageStorage {
    
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreData")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  var imageData: NSEntityDescription? {
    return  NSEntityDescription.entity(forEntityName: "ImageEntity", in: context)
  }
  
  func fetchStoredImages() -> [ImageEntity] {
    do {
  
      let data = try context.fetch(ImageEntity.fetchRequest()) as! [ImageEntity]
      return data
    }catch{
      print(error.localizedDescription)
    }
    return []
  }
  
  func insert(_ model: Image) {
    if let entity = imageData {
      let managedObject = NSManagedObject(entity: entity, insertInto: context)
      managedObject.setValue(model.id, forKey: "id")
      managedObject.setValue(model.memo, forKey: "memo")
      managedObject.setValue(model.imageURL, forKey: "imageURL")
      managedObject.setValue(true, forKey: "isLiked")
      save()
    }
  }
  
  func isSaved(id: String) -> Bool {
    guard let _ =  fetchStoredImages().filter({$0.id == id}).first
    else {return false}
    return true
  }
  
  func delete(_ model: Image) {
    guard let targetModel = fetchStoredImages().filter({$0.id == model.id}).first
    else {return}
    context.delete(targetModel)
    save()
  }
  
  func deleteAll(){
    let fetchResults = fetchStoredImages()
    for item in fetchResults {
      context.delete(item)
    }
    save()
  }
  
  
  private func save() {
    do {
      let startTime = CFAbsoluteTimeGetCurrent()
      try context.save()
      let endTime = CFAbsoluteTimeGetCurrent()
      let elapsedTime = endTime-startTime * 1000
      print(elapsedTime)
    }catch{
      print(error.localizedDescription)
    }
  }
  
}
