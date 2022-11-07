//
//  Request.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct RequsetComponent: Requestable {
  var endPoint: EndPoint
  var body: Data?
}

extension RequsetComponent {
  
  func buildRequest(apiConfigurator: APIConfigurable) -> URLRequest {
    var request = URLRequest(url: makeURL(apiConfigurator))
    request.httpMethod = endPoint.method.rawValue
    request.httpBody = body
    for (_,header) in apiConfigurator.headers.enumerated() {
      request.addValue(header.value, forHTTPHeaderField: header.key)
    }
    return request
  }
  
  private func makeURL(_ apiConfigurator: APIConfigurable) -> URL {
    var urlComponent = URLComponents()
    urlComponent.scheme = apiConfigurator.scheme
    urlComponent.host =  apiConfigurator.baseURL
    urlComponent.path = endPoint.path.rawValue
    urlComponent.queryItems = endPoint.queryItems
    
    guard let url = urlComponent.url else {
      preconditionFailure("Invalid URL components: \(urlComponent)")
    }
    
    return url
    }
  
}
