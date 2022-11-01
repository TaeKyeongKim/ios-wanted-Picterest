//
//  ServerPath.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

enum ServerPath: String {
  case showList = "/photos"
}

enum Query: String {
  case clientID = "client_id"
  case pageNumber = "page"
  case perPage = "per_page"
}
