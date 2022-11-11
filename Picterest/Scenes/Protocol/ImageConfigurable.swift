//
//  ImageConfigurable.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/30.
//

import Foundation

protocol ImageConfigurable {
  var imageList: Observable<[Image]> {get set}
  func fetchImages()
  func resetList()
  func updateLikeStatus()
  func toogleLikeState(item entity: Image, completion: @escaping ((Error?) -> Void))
  subscript(index: IndexPath) -> Image? { get }
}
