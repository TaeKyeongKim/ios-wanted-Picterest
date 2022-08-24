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
  
  func loadImage(urlSource: URL, completion: @escaping (Result<Data, Error>) -> Void) {
    let urlAsString = urlSource.lastPathComponent
    
    //MARK: Search Data in Memory
    if let data = imageCache.object(forKey: urlAsString as NSString) {
      completion(.success(data as Data))
      return
    }
    
    //MARK: Search Image data in Disk
    if let data = getSavedImage(named: urlAsString) {
      completion(.success(data))
      return
    }
    
    let URLRequest = URLRequest(url: urlSource)
    NetworkService.request(on: URLRequest) {[weak self] result in
      switch result{
      case .success(let data):
        completion(.success(data))
        self?.imageCache.setObject(data as NSData, forKey: urlAsString as NSString)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  
  func saveImage(_ model: ImageViewModel, completion: @escaping ((Error?) -> Void)) {
    //I want to save image as PNG or JPEG and when i get these Image out, i'd like to convert it into
    //Data type.
    guard let directory = makeDefaultPath(),
          let imageData = model.imageData
    else {return}
    do {
      try imageData.write(to: directory.appendingPathComponent(model.imageURL.lastPathComponent))
      coreDataManager.insert(model)
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
  
  func getSavedImage(named: String) -> Data? {
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
  
//  func convertDataToPng(imageData: Data?) -> Data? {
//    guard let data = imageData,
//          let image = UIImage(data: data),
//          let pngData = image.pngData()
//    else {
//      return nil
//    }
//    return pngData
//  }
}
