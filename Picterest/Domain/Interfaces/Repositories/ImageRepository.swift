//
//  ImageRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/17.
//

import Foundation

protocol ImageRepository {
  func fetchImages(endPoint: EndPoint, completion: @escaping (Result<[Image], NetworkError>) -> Void)
  func fetchSavedImageData() -> [ImageData]
  func saveImage(imageEntity: Image, completion: @escaping ((Error?) -> Void))
  func deleteImage(imageEntity: Image, completion: @escaping ((Error?) -> Void))
  func resetRepository(completion: @escaping ((Error?) -> Void))
}
