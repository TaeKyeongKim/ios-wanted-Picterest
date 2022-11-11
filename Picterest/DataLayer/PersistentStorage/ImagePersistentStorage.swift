//
//  CoreDataManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//


import CoreData

protocol ImagePersistentStorage {
  func fetchStoredImages(completion: @escaping (Result<[Image],Error>) -> Void)
  func insertImage(_ model: Image, completion: @escaping (Result<Image,Error>) -> Void)
  func delete(_ model: Image, completion: @escaping (Result<Image,Error>) -> Void)
}

final class CoreDataImagePersistentStorage: ImagePersistentStorage {

  private var storage = CoreDataStorage.shared
    
  init(coredataStorage: CoreDataStorage = CoreDataStorage.shared) {
    self.storage = coredataStorage
  }

  func fetchStoredImages(completion: @escaping (Result<[Image],Error>) -> Void) {
    storage.performBackgroundTask { context in
      do {
        let data = try context.fetch(ImageEntity.fetchRequest())
        completion(.success(data.map({$0.toDomain()})))
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

  func delete(_ model: Image, completion: @escaping (Result<Image,Error>) -> Void) {
    storage.performBackgroundTask { context in
      do {
        let data = try context.fetch(ImageEntity.fetchRequest())
        guard let deletionObject = data.filter({$0.id == model.id}).first else {return}
        context.delete(deletionObject)
        try context.save()
        completion(.success(model))
      }catch {
        completion(.failure(error))
      }
    }
    
  }

}
