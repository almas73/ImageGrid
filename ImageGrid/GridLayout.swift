//
//  GridLayout.swift
//  ImageGrid
//
//  Created by Almas Daumov on 5/10/16.
//  Copyright © 2016 Almas Daumov. All rights reserved.
//

import UIKit

protocol GridLayoutDelegate: UICollectionViewDataSource {
    func itemPaddingInCollectionView(_ collectionView: UICollectionView) -> CGFloat
    func numberOfColumnsInCollectionView(_ collectionView: UICollectionView) -> Int
    func collectionView(_ collecitionView: UICollectionView, sizeForItemAtIndexPath indexPath:IndexPath) -> CGSize
}

class GridLayout: UICollectionViewLayout {
  
    weak var delegate: GridLayoutDelegate!

    // Grid layout
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0

    override func prepare() {
        cachedAttributes.removeAll()

        let itemPadding = delegate.itemPaddingInCollectionView(collectionView!)
        let numberOfColumns = delegate.numberOfColumnsInCollectionView(collectionView!)
        let itemWidth = (collectionView!.bounds.width - (itemPadding * CGFloat(numberOfColumns + 1))) / CGFloat(numberOfColumns)

        var columnHeights = [CGFloat](repeating: 0, count: numberOfColumns)

        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let itemSize = delegate.collectionView(collectionView!, sizeForItemAtIndexPath: indexPath)

            let shortestColumnIndex = columnHeights.index(of: columnHeights.min()!)!
            let xOffset = CGFloat(shortestColumnIndex) * itemWidth + (itemPadding * CGFloat(shortestColumnIndex + 1))
            let yOffset = columnHeights[shortestColumnIndex] + itemPadding

            let frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame

            cachedAttributes.append(attributes)

            columnHeights[columnHeights.index(of: columnHeights.min()!)!] += (itemSize.height + itemPadding)
        }

        contentHeight = (columnHeights.max() ?? 0) + itemPadding
    }

    override var collectionViewContentSize : CGSize {
        return CGSize(width: collectionView!.bounds.width, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cachedAttributes {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if cachedAttributes.count > indexPath.item {
            return cachedAttributes[indexPath.item]
        }

        if let attributes = super.layoutAttributesForItem(at: indexPath) {
            return attributes
        }

        return UICollectionViewLayoutAttributes(forCellWith: indexPath)
    }

    override func invalidateLayout() {
        cachedAttributes.removeAll()
        contentHeight = 0
        super.invalidateLayout()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
}
