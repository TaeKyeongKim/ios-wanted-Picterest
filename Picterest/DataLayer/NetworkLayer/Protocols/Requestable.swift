//
//  Requestable.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

protocol Requestable {
  var body: Data? { get }
  var endPoint: EndPoint { get }
  func buildRequest(apiConfigurator: APIConfigurable) -> URLRequest
}

