//
//  Request.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

struct Requset: Requestable {
  var requestType: HTTPRequest
  var body: Data?
  var endPoint: EndPoint
}

extension Requset {
  var value: URLRequest {
    URLRequest.makeURLRequest(request: self)
  }
}
