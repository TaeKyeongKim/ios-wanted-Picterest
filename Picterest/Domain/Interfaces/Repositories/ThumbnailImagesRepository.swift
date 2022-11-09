//
//  ThumbnailImagesRepository.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/08.
//

import Foundation

protocol ThumbnailImagesRepository {
  func fetchImageData(with imageURL: URL, completion: @escaping (Result<Data, Error>) -> Void) 
}
