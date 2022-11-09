//
//  EndPoint.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

enum HTTPRequest: String {
  case get = "GET"
  case post = "POST"
}

enum ServerPath: String {
  case showList = "/photos"
  case noPath = ""
}

enum Query: String {
  case apiClient = "client_id"
  case pageNumber = "page"
  case perPage = "per_page"
}


struct EndPoint: EndPointable {
  
  var method: HTTPRequest
  let path: ServerPath
  var queryItems: [URLQueryItem]?
  
  init(method: HTTPRequest, path: ServerPath, query: QueryFactory){
    self.path = path
    self.queryItems = query.queryItems
    self.method = method
  }

}

extension EndPoint {
  static func getThumbnailImage() -> EndPoint {
    return EndPoint(method: .get, path: .noPath, query: .noQuery)
  }
}


