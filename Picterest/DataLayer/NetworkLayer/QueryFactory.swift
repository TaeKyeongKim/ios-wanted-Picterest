//
//  QueryMaker.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import Foundation

enum QueryFactory {

  case imagesPerPage(pageNumber: Int,perPage: Int)
  case noQuery
  
  var queryItems: [URLQueryItem]? {
    var baseQuery: [URLQueryItem] = []
    switch self {
    case .imagesPerPage(let pageNumber, let ImagePerPage):
      baseQuery.append(URLQueryItem(name: Query.pageNumber.rawValue,
                                    value: "\(pageNumber)"))
      baseQuery.append(URLQueryItem(name: Query.perPage.rawValue,
                                    value: "\(ImagePerPage)"))
      return baseQuery
    case .noQuery:
      return nil
    }
  }
}
