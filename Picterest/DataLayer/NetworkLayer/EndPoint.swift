//
//  EndPoint.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct EndPoint: EndPointable {
  let path: ServerPath
  var queryItems: [URLQueryItem]?
  
  init(path: ServerPath, query: QueryFactory){
    self.path = path
    self.queryItems = query.queryItems
  }
}

extension EndPoint {
  var url: URL {
    var urlComponent = URLComponents()
    urlComponent.scheme = scheme
    urlComponent.host = host
    urlComponent.path = path.rawValue
    urlComponent.queryItems = queryItems
    guard let url = urlComponent.url
    else
    {
      preconditionFailure("Invalid URL components: \(urlComponent)")
    }
    return url
  }
}


