//
//  CoreDataManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation
import CoreData

final class CoreDataManager {
  static var shared: CoreDataManager = CoreDataManager()
  
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
    return  NSEntityDescription.entity(forEntityName: "ImageData", in: context)
  }
  
  func fetchImages() -> [ImageEntity]? {
    do {
      let data = try context.fetch(ImageEntity.fetchRequest()) as! [ImageEntity]
      return data
    }catch{
      print(error.localizedDescription)
    }
    return nil
  }
  
  func insert(_ model: Image) {
    if let entity = imageData {
      let managedObject = NSManagedObject(entity: entity, insertInto: context)
      managedObject.setValue(model.id, forKey: "id")
      managedObject.setValue(model.memo, forKey: "memo")
      managedObject.setValue(model.imageURL, forKey: "imageURL")
      save()
    }
  }
  
  func isSaved(id: String) -> Bool {
    guard let fetchResults = fetchImages(),
          let _ = fetchResults.filter({$0.id == id}).first
    else {return false}
    return true
  }
  
  func delete(_ model: Image) {
    guard let fetchResults = fetchImages(),
          let targetModel = fetchResults.filter({$0.id == model.id}).first
    else {return}
    context.delete(targetModel)
    save()
  }
  
  func deleteAll(){
    guard let fetchResults = fetchImages()else {return}
    for item in fetchResults {
      context.delete(item)
    }
    save()
  }
  
  
  private func save() {
    do {
      try context.save()
    }catch{
      print(error.localizedDescription)
    }
  }
  
}
