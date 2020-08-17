//
//  SpreadsheetCollectionViewLayout.swift
//  TaskManagement
//
//  Created by Thanh Nguyen on 8/16/20.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import UIKit

protocol SpreadsheetCollectionViewLayoutDelegate: UICollectionViewDelegate {
    func width(forColumn column: Int, collectionView: UICollectionView) -> CGFloat
    func height(forRow row: Int, collectionView: UICollectionView) -> CGFloat
}

final class SpreadsheetCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: SpreadsheetCollectionViewLayoutDelegate!
    
    private var layoutAttributesCache: [UICollectionViewLayoutAttributes]!
    private var layoutAttributesInRectCache = CGRect.zero
    private var contentSizeCache = CGSize.zero
    private var columnCountCache = 0
    private var rowCountCache = 0
    
    private var originalContentOffset = CGPoint.zero
    
    override func prepare() {
       super.prepare()
    }
    
    override var collectionViewContentSize: CGSize {
        guard contentSizeCache.equalTo(CGSize.zero) else {
            return contentSizeCache
        }
        
        // Query the collection view's offset here. This method is executed exactly once.
        originalContentOffset = .zero // collectionView!.contentOffset
        rowCountCache = collectionView!.numberOfItems(inSection: 0)
        columnCountCache = collectionView!.numberOfSections
        
        var contentSize = CGSize(width: originalContentOffset.x, height: originalContentOffset.y)
        
        // Calculate the content size by querying the delegate. Perform this function only once.
        for column in 0..<columnCountCache {
            contentSize.width += delegate.width(
                forColumn: column, collectionView: collectionView!
            )
        }
        
        for row in 0..<rowCountCache {
            contentSize.height += delegate.height(
                forRow: row, collectionView: collectionView!
            )
        }
        
        contentSizeCache = contentSize
        
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemSize = CGSize(
            width: delegate.width(
                forColumn: indexPath.row, collectionView: collectionView!
            ),
            height: delegate.height(
                forRow: indexPath.section, collectionView: collectionView!
            )
        )
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        // Calculate the rect of the cell making sure to incorporate the off set of the collection
        // view's content.
        var frame = CGRect(
            x: (itemSize.width * CGFloat(indexPath.section)) + originalContentOffset.x,
            y: (itemSize.height * CGFloat(indexPath.row)) + originalContentOffset.y,
            width: itemSize.width,
            height: itemSize.height
        )
        
        switch (indexPath.section, indexPath.row) {
        // Top-left tem
        case (0, 0):
            attributes.zIndex = 2
            frame.origin.y = collectionView!.contentOffset.y
            frame.origin.x = collectionView!.contentOffset.x
            
        // Top row
        case (0, _):
            attributes.zIndex = 1
            frame.origin.x = collectionView!.contentOffset.x
            
        // Left column
        case (_, 0):
            attributes.zIndex = 1
            frame.origin.y = collectionView!.contentOffset.y
            
        default:
            attributes.zIndex = 0
        }
        
        attributes.frame = frame.integral
        if frame.origin.x > 1500 {
            print("==========\(indexPath.section)===\(indexPath.row)")
        }
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard !rect.equalTo(layoutAttributesInRectCache) else {
            return layoutAttributesCache
        }
        
        layoutAttributesInRectCache = rect
        
        var attributes = Set<UICollectionViewLayoutAttributes>()
        
        for column in 0..<columnCountCache {
            for row in 0..<rowCountCache {
                let attribute = layoutAttributesForItem(at: IndexPath(row: row, section: column))!
                
                attributes.insert(attribute)
            }
        }
        
        layoutAttributesCache = Array(attributes)
        
        return layoutAttributesCache
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        layoutAttributesCache = nil
        layoutAttributesInRectCache = CGRect.zero
    }

}
