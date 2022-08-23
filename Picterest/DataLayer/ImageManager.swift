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
  
  func loadImage(urlSource: ImageEntity, completion: @escaping (Data?) -> Void) {
    //MARK: Search Data in Memory
    if let data = imageCache.object(forKey: urlSource.imageURL.lastPathComponent as NSString) {
      completion(data as Data)
      return
    }
    
    //MARK: Search Image data in Disk
    if let image = getSavedImage(named: urlSource.imageURL.lastPathComponent) {
      completion(makeImageData(image: image))
      return
    }
    
    let URLRequest = URLRequest(url: urlSource.imageURL)
    NetworkService.request(on: URLRequest) {[weak self] result in
      switch result{
      case .success(let data):
        completion(data)
        self?.imageCache.setObject(data as NSData, forKey: urlSource.imageURL.lastPathComponent as NSString)
      case .failure(_):
        completion(nil)
      }
    }
  }

  
  func saveImage(_ imageEntity: ImageEntity, completion: @escaping ((Error?) -> Void)) {
    guard let directory = makeDefaultPath(),
          let imageData = makeImageData(image: imageEntity.image) else {return}
    do {
      try imageData.write(to: directory.appendingPathComponent(imageEntity.imageURL.lastPathComponent))
      coreDataManager.insert(imageEntity)
      completion(nil)
    } catch {
      completion(error)
    }
  }
  
  func loadSavedImage() -> [ImageData] {
    guard let data = coreDataManager.fetchImages() else {return []}
    return data
  }
  
  func deleteSavedImage(imageEntity: ImageEntity, completion: @escaping ((Error?) -> Void)) {
    guard let storedDirectory = getStoredDirectory(imageName: imageEntity.imageURL.lastPathComponent) else {return}
    do {
      try fileManager.removeItem(atPath: storedDirectory)
      coreDataManager.delete(imageEntity)
      completion(nil)
    }catch{
      completion(error)
    }
  }
  
  func clearStorage(completion: @escaping ((Error?) -> Void)) {
    let storedModels = coreDataManager.fetchImages()
    storedModels?.forEach({
      do {
        guard let storedDirectory = getStoredDirectory(imageName: $0.imageURL.lastPathComponent) else {return}
        try fileManager.removeItem(atPath: storedDirectory)
        coreDataManager.deleteAll()
      }
      catch{
        completion(error)
      }
    })
  }
  
  func getSavedImage(named: String) -> UIImage? {
    guard let path = getStoredDirectory(imageName: named) else {return nil}
    let image: UIImage? = UIImage(contentsOfFile: path)
    return image
  }
}

private extension ImageManager {
  
  func makeDefaultPath() -> URL? {
    if let directory = fileManager.urls(for: .documentDirectory,
                                        in: .userDomainMask).first {return directory}
    return nil
  }
  
  func getStoredDirectory(imageName: String) -> String? {
    if let dir = makeDefaultPath() {
      let path: String
      = URL(fileURLWithPath: dir.absoluteString)
        .appendingPathComponent(imageName).path
      return path
    }
    return nil
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
