//
//  ImageRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/17.
//

import Foundation

protocol ImageRepository {
  func fetchImages(endPoint: EndPoint, completion: @escaping (Result<[ImageEntity], NetworkError>) -> Void)
  func fetchSavedImageData() -> [ImageData]
  func saveImage(imageEntity: ImageEntity, completion: @escaping ((Error?) -> Void))
  func deleteImage(imageEntity: ImageEntity, completion: @escaping ((Error?) -> Void))
  func resetRepository(completion: @escaping ((Error?) -> Void))
}
