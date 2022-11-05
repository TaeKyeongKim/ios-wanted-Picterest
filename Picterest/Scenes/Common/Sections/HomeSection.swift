//
//  HomeSection.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/06.
//

import Foundation

enum HomeSection: Int, CaseIterable {
  case mainContent
  
  var numberOfColumns: Int {
    switch self {
    case .mainContent:
      return 2
    }
  }
  
  var numberOfItemsPerPage: Int {
    switch self {
    case .mainContent:
      return 15
    }
  }
  
  static func getNumberOfSections() -> Int {
    return self.allCases.count
  }
}
