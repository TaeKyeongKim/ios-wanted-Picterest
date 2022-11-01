//
//  NetworkService.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

protocol DataTransferService {
  func request(on endPoint: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

struct NetworkService: DataTransferService {
  
  func request(on endPoint: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void) {
    
    URLSession.shared.dataTask(with: endPoint) { data, response, error in
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
