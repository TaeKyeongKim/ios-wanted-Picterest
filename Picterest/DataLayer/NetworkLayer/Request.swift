//
//  Request.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct RequsetComponent: Requestable {
  var endPoint: EndPointable
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
  
  //Make URL with informations from api configurator and endPoint
  private func makeURL(_ apiConfigurator: APIConfigurable) -> URL {
    var urlComponent = URLComponents()
    urlComponent.scheme = apiConfigurator.scheme
    urlComponent.host =  apiConfigurator.baseURL
    urlComponent.path = endPoint.path.rawValue
    if let queryItems = endPoint.queryItems {
      urlComponent.queryItems = queryItems + [URLQueryItem(name:Query.apiClient.rawValue, value: apiConfigurator.apiKey)]
    }

    guard let url = urlComponent.url else {
      preconditionFailure("Invalid URL components: \(urlComponent)")
    }
    
    return url
    }
  
}
