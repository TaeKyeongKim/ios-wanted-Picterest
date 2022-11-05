//
//  LayoutConfigurator.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/05.
//

import UIKit

protocol LayoutConfigurable {
  var numberOfColumns: Int { get }
  var section: Int { get }
  var cellPadding: CGFloat { get }
  var cacheOptions: [cacheType] { get }
  var numberOfItemsPerPage: Int? { get }
}

struct LayoutConfigurator: LayoutConfigurable {
  let numberOfColumns: Int
  let section: Int
  let cellPadding: CGFloat
  let cacheOptions: [cacheType]
  let numberOfItemsPerPage: Int?
}
