//
//  NetworkService.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

protocol NetworkService {
  typealias CompletionHandler = (Result<Data, NetworkError>) -> Void
  func request(on endPoint: Requestable, completion: @escaping CompletionHandler)
  func request(on rawURL: URL, completion: @escaping CompletionHandler)
}

final class DefaultNetworkService: NetworkService {

  let apiConfig: APIConfigurable?
  
  init(apiConfig: APIConfigurable?) {
    self.apiConfig = apiConfig
  }

  func request(on urlRequest: URLRequest, completion: @escaping CompletionHandler) {
    
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      if let error = error {
        completion(.failure(.transportError(error)))
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        let response = response as? HTTPURLResponse
        completion(.failure(.serverError(statusCode: response?.statusCode)))
        return
      }
      
      guard let data = data else {
        completion(.failure(.noData))
        return
      }
      
      completion(.success(data))
    }.resume()
    
  }
}

extension DefaultNetworkService {
  
  func request(on requestComponent: Requestable, completion: @escaping CompletionHandler) {
      guard let apiconfig = apiConfig else {return}
      let urlRequest = requestComponent.buildRequest(apiConfigurator: apiconfig)
      return request(on: urlRequest, completion: completion)
  }
  
  func request(on rawURL: URL, completion: @escaping CompletionHandler) {
    let urlRequest = URLRequest(url: rawURL)
    return request(on: urlRequest, completion: completion)
  }
  
}
