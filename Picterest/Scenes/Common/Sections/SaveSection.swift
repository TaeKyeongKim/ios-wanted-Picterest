//
//  SaveSection.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/06.
//

import Foundation

enum SaveSection: Int, CaseIterable {
  case mainContent
  
  var numberOfColumns: Int {
    switch self {
    case .mainContent:
      return 1
    }
  }
  
  var numberOfItemsPerPage: Int? {
    switch self {
    case .mainContent:
      return nil
    }
  }
  
  static func getNumberOfSections() -> Int {
    return self.allCases.count
  }
}
