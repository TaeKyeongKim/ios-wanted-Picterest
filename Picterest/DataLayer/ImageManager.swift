//
//  ImageManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

final class ImageManager {
  
  static let shared = ImageManager()
  private let fileManager =  FileManager.default
  private let coreDataManager = CoreDataManager.shared
  private var imageCache = NSCache<NSString,NSData>()
  
  private init(){}
  
  func loadImage(urlSource: ImageEntity, completion: @escaping (Result<Data?,Error>) -> Void) {
    //MARK: Search Data in Memory
    if let data = imageCache.object(forKey: urlSource.imageURL.lastPathComponent as NSString) {
      completion(.success(data as Data))
      return
    }
    
    //MARK: Search Image data in Disk
    getSavedImage(named: urlSource.imageURL.lastPathComponent) { result in
      if case let .success(image) = result {
        completion(.success(self.makeImageData(image: image)))
      }
    }
    
    let URLRequest = URLRequest(url: urlSource.imageURL)
    NetworkService.request(on: URLRequest) {[weak self] result in
      switch result{
      case .success(let data):
        completion(.success(data))
        self?.imageCache.setObject(data as NSData, forKey: urlSource.imageURL.lastPathComponent as NSString)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  
  func saveImage(_ imageEntity: ImageEntity, completion: @escaping ((Error?) -> Void)) {
    guard let directory = makePath(with: imageEntity.imageURL),
          let imageData = makeImageData(image: imageEntity.image) else {return}
    //TODO: remove saveStoredDirectory 이걸로 안씀.
    imageEntity.saveStoredDirectory(url: directory.appendingPathComponent(imageEntity.imageURL.lastPathComponent))
    do {
      try imageData.write(to: directory.appendingPathComponent(imageEntity.imageURL.lastPathComponent))
      coreDataManager.insert(imageEntity)
      completion(nil)
    } catch {
      completion(error)
    }
  }
  
  func loadSavedImage() -> [ImageEntity] {
    guard let data = coreDataManager.fetchImages() else {return []}
    return data
  }
  
  enum DataPersistenceError: Error {
    
    case DirectoryNotFound(for: String)
    case ImageNotFoundInCoreData
  }
  
  func deleteSavedImage(imageEntity: ImageEntity, completion: @escaping ((Error?)-> Void)) {
    getStoredDirectory(imageName: imageEntity.imageURL.lastPathComponent) { result in
      switch result {
      case .success(let path):
        do {
          try self.fileManager.removeItem(atPath: path)
          self.coreDataManager.delete(imageEntity)
        }catch{
          completion(error)
          return
        }
      case .failure(let error):
        completion(error)
      }
    }
  }

  func clearStorage(completion: @escaping (Result<Void,Error>) -> Void) {
    let storedModels = coreDataManager.fetchImages()
    storedModels?.forEach({
        getStoredDirectory(imageName: $0.imageURL.lastPathComponent){ result in
          switch result {
          case.success(let path):
            do {
              try self.fileManager.removeItem(atPath: path)
            }catch {
              completion(.failure(error))
            }
          case .failure(let error):
            completion(.failure(error))
            return
          }
        }
        coreDataManager.deleteAll()
      })
  }
   
                          
  
  func getSavedImage(named: String, completion: @escaping (Result<UIImage?,Error>) -> Void) {
    self.getStoredDirectory(imageName: named) { result in
      switch result {
      case .success(let path):
        let image: UIImage? = UIImage(contentsOfFile: path)
        completion(.success(image))
        return
      case .failure(let error):
        completion(.failure(error))
        return
      }
    }
  }
}

private extension ImageManager {
  
  func getStoredDirectory(imageName: String, completion: @escaping (Result<String,Error>) -> Void) {
    do {
      let dir: URL
          = try FileManager.default.url(for: .downloadsDirectory,
                                         in: .userDomainMask,
                                         appropriateFor: nil,
                                         create: false)
      let path: String
      = URL(fileURLWithPath: dir.absoluteString)
        .appendingPathComponent(imageName).path
      
      completion(.success(path))
      return
    }catch{
      completion(.failure(error))
      return
    }
        
  }
  
  func makePath(with url: URL) -> URL? {
    guard let directory = try? FileManager.default.url(for: .downloadsDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) as URL
    else {
      return nil
    }
    return directory
  }

  func makeImageData(image: UIImage?) -> Data? {
    guard let image = image,
          let data = image.jpegData(compressionQuality: 1) ?? image.pngData()
    else {
      return nil
    }
    return data
  }
}
