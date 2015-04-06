//
//  ProjectLayout.swift
//  PicFlow++
//
//  Created by Sheen on 4/6/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation

class ProjectLayout : UICollectionViewLayout {
    
    var itemInsets:UIEdgeInsets?;
    var itemSize:CGSize?;
    var interItemSpacingY:CGFloat?;
    var numberOfColumns:NSInteger?;
    var LayoutPhotoCellKind:String = "PhotoCell";
    var layoutInfo:NSDictionary?
 
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
         super.init()
    }
    
    func setup(){
        self.itemInsets = UIEdgeInsetsMake(22.0, 22.0, 13.0, 22.0);
        self.itemSize = CGSizeMake(125.0, 125.0);
        self.interItemSpacingY = 12.0;
        self.numberOfColumns = 2;
    }
    
    func frameForAlbumPhotoAtIndexPath(indexPath:NSIndexPath) -> CGRect
    {
        
        var row:NSInteger = indexPath.section / self.numberOfColumns!;
        var column: NSInteger = indexPath.section % self.numberOfColumns!;
        
        var width = (CGFloat(self.numberOfColumns!) *   self.itemSize!.width)
        var spacingX:CGFloat = self.collectionView!.bounds.size.width - self.itemInsets!.left - self.itemInsets!.right - width
        
        if (self.numberOfColumns > 1){
            
            spacingX = spacingX / CGFloat(self.numberOfColumns! - 1)
        }

        var originX:CGFloat = CGFloat(floorf(Float(self.itemInsets!.left + (self.itemSize!.width + spacingX) * CGFloat(column))))
        var originY:CGFloat = CGFloat(floorf(Float(self.itemInsets!.top + (self.itemSize!.height + self.interItemSpacingY!) * CGFloat(row))))
 
        return CGRectMake(originX, originY, self.itemSize!.width, self.itemSize!.height);
    }
    
    
    override func prepareLayout()
    {
        var newLayoutInfo: NSMutableDictionary = NSMutableDictionary();
        var cellLayoutInfo:NSMutableDictionary = NSMutableDictionary();
    
        var sectionCount:NSInteger = self.collectionView!.numberOfSections();
        var indexPath:NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        for (var section:NSInteger = 0; section < sectionCount; section++) {
            var itemCount:NSInteger = self.collectionView!.numberOfItemsInSection(section)
    
            for (var item:NSInteger = 0; item < itemCount; item++) {
                indexPath = NSIndexPath(forItem: item, inSection: section)
    
                var itemAttributes:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                itemAttributes.frame = self.frameForAlbumPhotoAtIndexPath(indexPath)
                cellLayoutInfo[indexPath] = itemAttributes;
            }
   
        }
    
        newLayoutInfo[LayoutPhotoCellKind] = cellLayoutInfo;
        self.layoutInfo = newLayoutInfo;
    }
   
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]?
    {
        var stop:Bool = false
        var allAttributes: NSMutableArray  = NSMutableArray(capacity:self.layoutInfo!.count )
        
        self.layoutInfo!.enumerateKeysAndObjectsUsingBlock { (elementIdentifier, elementsInfo, stop) -> Void in
        
            elementsInfo.enumerateKeysAndObjectsUsingBlock{(indexPath,attributes,innerStop) -> Void in
            
                    if (CGRectIntersectsRect(rect, attributes.frame)) {
                        allAttributes.addObject(attributes);
                    }

            }
        }
        
        
        return allAttributes;
    }

}