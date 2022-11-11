//
//  LayoutManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

protocol CustomLayoutDelegate: AnyObject {
  func collectionView(_ collectionView: UICollectionView,
                      didSetWidthRatioAt indexPath: IndexPath) -> CGFloat
}

enum cacheType {
  case items
  case footer
}

final class CustomLayout: UICollectionViewLayout {
  
  weak var delegate: CustomLayoutDelegate?
  let layoutConfigurator: LayoutConfigurable
  private var contentHeight: CGFloat = 0
  private var contentWidth: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right)
  }
  
  lazy var numberOfColumns: Int = {
    return layoutConfigurator.numberOfColumns
  }()
    
  lazy var columnWidth: CGFloat = {
    return (contentWidth / CGFloat(numberOfColumns))
  }()

  lazy var cache: [cacheType: [UICollectionViewLayoutAttributes]] = {
    var cache: [cacheType: [UICollectionViewLayoutAttributes]] = [:]
    for cacheOption in layoutConfigurator.cacheOptions {
      cache.updateValue([], forKey: cacheOption)
    }
    return cache
  }()
  
  lazy var widthPerItem: CGFloat = {
    return contentWidth / CGFloat(layoutConfigurator.numberOfColumns)
  }()
  
  lazy var paddingPerItem: CGFloat = {
    return layoutConfigurator.cellPadding * CGFloat(layoutConfigurator.numberOfColumns)
  }()
  
  init(layoutConfigurator: LayoutConfigurable) {
    self.layoutConfigurator = layoutConfigurator
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

private extension CustomLayout {
  
  func resetCache() {
    cache.updateValue([], forKey: .items)
    cache.updateValue([], forKey: .footer)
  }
  
  func makeIndexPath(at item: Int) -> IndexPath {
    return IndexPath(item: item, section: layoutConfigurator.section)
  }
  
  func computeContentHeight(widthRatio: CGFloat) -> CGFloat {
    let heightRatio = (widthPerItem - paddingPerItem) / widthRatio
    return layoutConfigurator.cellPadding * 2 + heightRatio
  }
  
  
  func updateItemCacheAttribute(on itemIndex: IndexPath, currentFrame: CGRect) {
    if var itemAttributeCache = cache[.items] {
      let insetFrame = currentFrame.insetBy(dx: layoutConfigurator.cellPadding, dy: layoutConfigurator.cellPadding)
      let attributes = UICollectionViewLayoutAttributes(forCellWith:itemIndex)
      attributes.frame = insetFrame
      itemAttributeCache.append(attributes)
      cache.updateValue(itemAttributeCache, forKey: .items)
    }
  }
  
  func updateFooterCacheAttribute(on itemIndex: Int, currentFrame: CGRect) {
    if let itemsPerPage = layoutConfigurator.numberOfItemsPerPage, ((itemIndex + 1) % itemsPerPage == 0) {
      let footerAtrributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter,
                                                              with:IndexPath(item: itemIndex,section: layoutConfigurator.section))
      
      footerAtrributes.frame = CGRect(x: 0, y: max(contentHeight, currentFrame.maxY),
                                      width: UIScreen.main.bounds.width, height: 50)
      if var footerAttributeCache = cache[.footer] {
        footerAttributeCache.removeAll()
        footerAttributeCache.append(footerAtrributes)
        cache.updateValue(footerAttributeCache, forKey: .footer)
      }
    }
  }

}


extension CustomLayout {
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func prepare() {
    super.prepare()
    guard let collectionView = collectionView else {return}
    
    //Reset
    resetCache()
    let xOffset: [CGFloat] = Array(0..<numberOfColumns).map({CGFloat($0)*columnWidth})
    var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
    var currentColumn = 0
    
    for itemIndex in 0..<collectionView.numberOfItems(inSection: layoutConfigurator.section) {

      let indexPath = makeIndexPath(at: itemIndex)
      let itemWidthRatio = delegate?.collectionView(collectionView, didSetWidthRatioAt: indexPath) ?? 0
      let height = computeContentHeight(widthRatio: itemWidthRatio)
      let frame = CGRect(x: xOffset[currentColumn],y: yOffset[currentColumn],width: columnWidth,height: height)
      
      updateItemCacheAttribute(on: indexPath, currentFrame: frame)
      contentHeight = frame.maxY
      yOffset[currentColumn] = yOffset[currentColumn] + height
      
      let nextColumn = currentColumn < numberOfColumns-1 ? currentColumn+1 : 0
      currentColumn = yOffset[currentColumn] < yOffset[nextColumn] ? currentColumn : nextColumn
      
      if layoutConfigurator.cacheOptions.contains(cacheType.footer) {
        updateFooterCacheAttribute(on: itemIndex, currentFrame: frame)
      }
    }
    
  }
  
  override func layoutAttributesForElements(in rect: CGRect)
  -> [UICollectionViewLayoutAttributes]? {
    var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    guard let itemsAttributes = cache[.items],!itemsAttributes.isEmpty
    , let footerAttributes = cache[.footer]
    else
    {
      return nil
    }
    
    for attributes in itemsAttributes {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    
    if let footerAttribute = footerAttributes.first,
       footerAttribute.representedElementKind == UICollectionView.elementKindSectionFooter {
      visibleLayoutAttributes.append(footerAttribute)
    }
    return visibleLayoutAttributes
  }
  
  
  override func layoutAttributesForItem(at indexPath: IndexPath)
  -> UICollectionViewLayoutAttributes? {
    guard let itemsAttributes = cache[.items],!itemsAttributes.isEmpty
    else {
      return nil
    }
    return itemsAttributes[indexPath.item]
  }
  
}


