//
//  NetworkConfig.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/06.
//

import Foundation

struct DefaultApiConfiguration: APIConfigurable {
  let scheme: String
  let baseURL: String
  let headers: [String: String]
  
  init(baseURL: String, headers: [String: String] , scheme: String) {
    self.baseURL = baseURL
    self.headers = headers
    self.scheme = scheme
  }
}
