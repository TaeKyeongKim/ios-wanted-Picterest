//
//  ImageManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit
//
//final class ImageManager {
//  
//  static let shared = ImageManager()
//  private let coreDataManager: ImageStorage = CoreDataManager()
//  
//  private init(){}
//  
//  func loadImage(urlSource: ImageEntity, completion: @escaping (Result<Data?,Error>) -> Void) {
//    
//    //MARK: Search Data in Memory
////    if let data = imageCache.object(forKey: urlSource.imageURL.lastPathComponent as NSString) {
////      completion(.success(data as Data))
////      return
////    }
////
////    //MARK: Search Image data in Disk
////    getSavedImage(named: urlSource.imageURL.lastPathComponent) { result in
////      if case let .success(image) = result {
////        completion(.success(self.makeImageData(image: image)))
////      }
////    }
//    
//    let URLRequest = URLRequest(url: urlSource.imageURL)
//    NetworkService.request(on: URLRequest) {[weak self] result in
//      switch result{
//      case .success(let data):
//        completion(.success(data))
//        self?.imageCache.setObject(data as NSData, forKey: urlSource.imageURL.lastPathComponent as NSString)
//      case .failure(let error):
//        completion(.failure(error))
//      }
//    }
//  }
//}
