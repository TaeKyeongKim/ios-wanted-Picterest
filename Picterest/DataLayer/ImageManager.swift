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
    if let imageData = getSavedImage(named: urlAsString) {
      completion(.success(imageData))
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
  
  
  func saveImage(_ model: Image, completion: @escaping ((Error?) -> Void)) {
    guard let directory = makeDefaultPath() else {return}
    loadImage(urlSource: model.imageURL) { [weak self] result in
      switch result {
      case .success(let imageData):
        do {
          try imageData.write(to: directory.appendingPathComponent(model.imageURL.lastPathComponent))
          self?.coreDataManager.insert(model)
          completion(nil)
        } catch {
          completion(error)
        }
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  func loadSavedImage() -> [ImageEntity] {
    coreDataManager.fetchImages()
  }
  
  func deleteSavedImage(imageEntity: Image, completion: @escaping ((Error?) -> Void)) {
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
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let directoryURL = documentsURL.appendingPathComponent("picteresting")
    if fileManager.fileExists(atPath: directoryURL.path) {
      do {
        try fileManager.removeItem(at: directoryURL)
        coreDataManager.deleteAll()
      }
      catch{
        completion(error)
      }
    }
  }
  
  func getSavedImage(named: String) -> Data? {
    guard let path = getStoredDirectory(imageName: named) else {return nil}
    let image: UIImage? = UIImage(contentsOfFile: path)
    let imageData = image?.jpegData(compressionQuality: 1)
    return imageData
  }
}

private extension ImageManager {
  
  func makeDefaultPath() -> URL? {
    guard var directory = fileManager.urls(for: .documentDirectory,
                                           in: .userDomainMask).first else {return nil}
    directory.appendPathComponent("picteresting")
    if !fileManager.fileExists(atPath: directory.path){
      do {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: false)
      }catch {
        print(error.localizedDescription)
      }
    }
    return directory
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
  

}
