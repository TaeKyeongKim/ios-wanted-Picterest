//
//  Requestable.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

enum HTTPRequest: String {
  case get = "GET"
  case post = "POST"
}

protocol Requestable {
  var requestType: HTTPRequest {get}
  var body: Data? {get}
  var endPoint: EndPoint {get}
  var value: URLRequest {get}
}

