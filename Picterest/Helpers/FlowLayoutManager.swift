//
//  LayoutManager.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

protocol SceneLayoutDelegate: AnyObject {
  func collectionView(_ collectionView: UICollectionView,
                      heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

enum SceneType: Int {
  case save = 1
  case home
}

final class SceneLayout: UICollectionViewLayout {
  
  weak var delegate: SceneLayoutDelegate?
  let numberOfColumns: Int
  let cellPadding: CGFloat
  private var cache: [cacheType: [UICollectionViewLayoutAttributes]] = [.items:[], .footer:[]]
  private var contentHeight: CGFloat = 0
  private var contentWidth: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right)
  }
  enum cacheType {
    case items
    case footer
  }
  
  init(scene: SceneType, cellPadding: CGFloat){
    self.numberOfColumns = scene.rawValue
    self.cellPadding = cellPadding
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}


extension SceneLayout {
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func prepare() {
    super.prepare()
    guard let collectionView = collectionView else {
      return
    }
    
    //Reset
    cache.updateValue([], forKey: .items)
    cache.updateValue([], forKey: .footer)
    contentHeight = 0
    
    //CollectionView 넣어주면...
    let columnWidth = (contentWidth / CGFloat(numberOfColumns))
    
    var xOffset: [CGFloat] = []
    for column in 0..<numberOfColumns {
      xOffset.append(CGFloat(column) * columnWidth)
    }
    var column = 0
    var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
    
    for item in 0..<collectionView.numberOfItems(inSection: 0) {
      let indexPath = IndexPath(item: item, section: 0)
      
      //9
      let photoHeight = delegate?.collectionView(
        collectionView, heightForPhotoAtIndexPath: indexPath) ?? 0
      let height = cellPadding * 2 + photoHeight
      
      let frame = CGRect(x: xOffset[column],
                         y: yOffset[column],
                         width: columnWidth,
                         height: height)
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
      
      //10
      let attributes = UICollectionViewLayoutAttributes(forCellWith:
                                                          indexPath)
      attributes.frame = insetFrame
      guard var itemAttribute = cache[.items]
      else {
        return
      }
      itemAttribute.append(attributes)
      cache.updateValue(itemAttribute, forKey: .items)
      
      //11
      contentHeight = max(contentHeight, frame.maxY)
      yOffset[column] = yOffset[column] + height
      
      if numberOfColumns == SceneType.save.rawValue {
        continue
      }
      let otherCol = column == 0 ? 1:0
      column = yOffset[column] < yOffset[otherCol] ? column : otherCol

      if ((item + 1) % 15 == 0) {
        let footerAtrributes = UICollectionViewLayoutAttributes(
          forSupplementaryViewOfKind:
            UICollectionView.elementKindSectionFooter,
          with: 
            IndexPath(
              item: item,
              section: 0)
        )
        footerAtrributes.frame = CGRect(x: 0, y: max(contentHeight, frame.maxY),
                                        width: UIScreen.main.bounds.width, height: 50)
        
        
        guard var footerAttribute = cache[.footer] else {return}
        footerAttribute.removeAll()
        footerAttribute.append(footerAtrributes)
        cache.updateValue(footerAttribute, forKey: .footer)
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
