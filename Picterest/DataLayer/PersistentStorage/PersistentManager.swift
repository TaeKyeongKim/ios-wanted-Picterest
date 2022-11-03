//
//  CoreDataManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//


import CoreData

protocol PersistentManager {
  func fetchStoredImages(completion: @escaping (Result<[ImageEntity],Error>) -> Void)
  func insertImage(_ model: Image, completion: @escaping (Result<Image,Error>) -> Void)
}

final class CoreDataManager: PersistentManager {

  private var storage = CoreDataStorage.shared
    
  init(coredataStorage: CoreDataStorage = CoreDataStorage.shared) {
    self.storage = coredataStorage
  }

  func fetchStoredImages(completion: @escaping (Result<[ImageEntity],Error>) -> Void) {
    storage.performBackgroundTask { context in
      do {
        let data = try context.fetch(ImageEntity.fetchRequest())
        completion(.success(data))
      }catch{
        completion(.failure(CoreDataStorageError.readError(error)))
      }
    }
  }
  
  func insertImage(_ model: Image, completion: @escaping (Result<Image,Error>) -> Void) {
    storage.performBackgroundTask { context in
      do {
        let managedObject = ImageEntity(context: context)
        managedObject.id = model.id
        managedObject.width = model.width
        managedObject.height = model.height
        managedObject.memo = model.memo
        managedObject.imageURL = model.imageURL
        managedObject.isLiked = model.isLiked
        try context.save()
        
        completion(.success(model))
      }catch let Error {
        completion(.failure(CoreDataStorageError.saveError(Error)))
      }
    }
  }
  
//  func isSaved(id: String) -> Bool {
//    guard let _ =  fetchStoredImages().filter({$0.id == id}).first
//    else {return false}
//    return true
//  }
  
//  func delete(_ model: Image) {
//    guard let targetModel = fetchStoredImages().filter({$0.id == model.id}).first
//    else {return}
//    context.delete(targetModel)
//    save()
//  }
  
//  func deleteAll(){
//    let fetchResults = fetchStoredImages()
//    for item in fetchResults {
//      context.delete(item)
//    }
//    save()
//  }
  
//  private func save() {
//    do {
//      let startTime = CFAbsoluteTimeGetCurrent()
//      try context.save()
//      let endTime = CFAbsoluteTimeGetCurrent()
//      let elapsedTime = endTime-startTime * 1000
//      print(elapsedTime)
//    }catch{
//      print(error.localizedDescription)
//    }
//  }
  
}
