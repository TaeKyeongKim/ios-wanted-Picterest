//
//  NetworkConfig.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/06.
//

import Foundation

struct DefaultApiConfiguration: APIConfigurable {
  let apiKey: String
  let scheme: String
  let baseURL: String
  let headers: [String: String]
  
  init(apiKey: String, baseURL: String, headers: [String: String] , scheme: String) {
    self.apiKey = apiKey
    self.baseURL = baseURL
    self.headers = headers
    self.scheme = scheme
  }
}
