//
//  ImageRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/08/17.
//

import Foundation

protocol ImageRepository {
  func fetchImages(endPoint: EndPoint, completion: @escaping (Result<[Image], Error>) -> Void)
  func fetchSavedImage(completion: @escaping (Result<[ImageEntity], Error>) -> Void)
  func saveImage(_ image: Image, completion: @escaping (Result<Image, Error>) -> Void)
//  func deleteImage(_ image: Image, completion: @escaping ((Error?) -> Void))
//  func resetRepository(completion: @escaping ((Error?) -> Void))
}
