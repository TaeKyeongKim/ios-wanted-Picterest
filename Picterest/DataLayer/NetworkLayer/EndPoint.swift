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
}

enum Query: String {
  case clientID = "client_id"
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


