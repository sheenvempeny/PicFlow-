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
    let RotationCount:NSInteger = 32;
    let RotationStride:NSInteger = 3;
    var rotations:[CATransform3D] = []
    let PhotoCellBaseZIndex:NSInteger = 100
 
    override init() {
        super.init()
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
         super.init()
         self.setup()
    }
    
    func setup(){
        self.itemInsets = UIEdgeInsetsMake(32.0, 32.0, 32.0, 32.0);
        self.itemSize = CGSizeMake(144.0, 144.0);
        self.interItemSpacingY = 26.0;
        self.numberOfColumns = 2;
        
        var _rotations:[CATransform3D] = []
        var  difference:CGFloat = 0
        var percentage:CGFloat = 0
        for (var i = 0; i < RotationCount; i++) {
            // ensure that each angle is different enough to be seen
            var newPercentage:CGFloat = 0
            do {
                newPercentage =  (CGFloat(arc4random() % 220) - 110) * 0.0001
                difference = CGFloat(fabsf(Float(percentage) - Float(newPercentage)))
            } while (difference < 0.006);
            percentage = newPercentage;
            
            var angle:CGFloat = 2 * CGFloat(M_PI) * (1 + percentage);
            var transform:CATransform3D = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0);
            
            _rotations.append(transform)
            
           
        }
        
        self.rotations = _rotations;
    }
    
    func frameForAlbumPhotoAtIndexPath(indexPath:NSIndexPath) -> CGRect
    {
        var originX:CGFloat = 0
        var originY:CGFloat = 0
        if( self.numberOfColumns != nil)
        {
          
            var row:NSInteger = indexPath.section / self.numberOfColumns!;
            var column: NSInteger = indexPath.section % self.numberOfColumns!;
            
            var width = (CGFloat(self.numberOfColumns!) *   self.itemSize!.width)
            var spacingX:CGFloat = self.collectionView!.bounds.size.width - self.itemInsets!.left - self.itemInsets!.right - width
            
            if (self.numberOfColumns > 1){
                
                spacingX = spacingX / CGFloat(self.numberOfColumns! - 1)
            }
            
                originX = CGFloat(floorf(Float(self.itemInsets!.left + (self.itemSize!.width + spacingX) * CGFloat(column))))
                originY = CGFloat(floorf(Float(self.itemInsets!.top + (self.itemSize!.height + self.interItemSpacingY!) * CGFloat(row))))
        }
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
                itemAttributes.transform3D = self.transformForAlbumPhotoAtIndex(indexPath)
                itemAttributes.zIndex = PhotoCellBaseZIndex + 80 - item;
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

    override func layoutAttributesForItemAtIndexPath(indexPath:NSIndexPath) -> UICollectionViewLayoutAttributes
    {
       var dict:NSDictionary  = self.layoutInfo!.objectForKey(LayoutPhotoCellKind) as NSDictionary
        var attrs = dict.objectForKey(indexPath) as UICollectionViewLayoutAttributes
        return attrs
    }
    
    override func collectionViewContentSize() -> CGSize
    {
        var returnSize:CGSize = self.collectionView!.bounds.size
        
        if(self.numberOfColumns != nil)
        {
            var rowCount:NSInteger = self.collectionView!.numberOfSections() / self.numberOfColumns!
            // make sure we count another row if one is only partially filled
            if (self.collectionView!.numberOfSections() % self.numberOfColumns! > 0){
                rowCount++;
            }
            
            var height:CGFloat = self.itemInsets!.top + (CGFloat(rowCount) * self.itemSize!.height) + CGFloat(rowCount - 1) * self.interItemSpacingY! + self.itemInsets!.bottom;
            returnSize = CGSizeMake(self.collectionView!.bounds.size.width, height);
        }
        
        return returnSize;
    }
    
    func transformForAlbumPhotoAtIndex(indexPath:NSIndexPath) -> CATransform3D
    {
    
        var offset:NSInteger = (indexPath.section * RotationStride + indexPath.item);
        var returnVal = self.rotations[offset % RotationCount] as CATransform3D
        return returnVal;
    }
    
    func setItemInsets(inItemInsets:UIEdgeInsets)
    {
        if (UIEdgeInsetsEqualToEdgeInsets(inItemInsets, itemInsets!) == true) {
            
            return;
        }
    
        itemInsets = inItemInsets;
        self.invalidateLayout()
        
    }
    
    func setItemSize(inItemSize:CGSize)
    {
        if (CGSizeEqualToSize(itemSize!, inItemSize) == true){
            return;
        }
        itemSize = inItemSize;
        self.invalidateLayout()
    }
    
    func setInterItemSpacingY(InInterItemSpacingY:CGFloat)
    {
        if (interItemSpacingY == InInterItemSpacingY){
            return;
        }
        interItemSpacingY =  InInterItemSpacingY;
        self.invalidateLayout()
    }
    
    func setNumberOfColumns(InNumberOfColumns:NSInteger)
    {
        if (numberOfColumns == InNumberOfColumns){
            return;
        }
        
        numberOfColumns = InNumberOfColumns;
        self.invalidateLayout()
    }
}