//
//  EndPointable.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

protocol EndPointable {
  var method: HTTPRequest { get }
  var path: ServerPath { get }
  var queryItems: [URLQueryItem]? { get }
}
