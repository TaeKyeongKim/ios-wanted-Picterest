//
//  APIConfigurable.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/06.
//

import Foundation

protocol APIConfigurable {
  var apiKey: String { get }
  var scheme: String { get }
  var baseURL: String { get }
  var headers: [String: String] { get }
}
