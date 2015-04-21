//
//  ProjectsCollectionManager.swift
//  PicFlow++
//
//  Created by Sheen on 4/6/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation


protocol ProjectsCollectionProtocol
{
    
   func projectSelectionChanged(project:Project);
    
}


class ProjectsCollectionManager:NSObject,UICollectionViewDataSource,UICollectionViewDelegate
{
    
    var collectionView:UICollectionView?
    var projects:[Project] = []
    var PhotoCellIdentifier = "PhotoCell";
    var delegate:ProjectsCollectionProtocol?
    
    init(inCollectionView:UICollectionView, withProjects inProjects:[Project]) {
    
        super.init()
        collectionView = inCollectionView
        projects = inProjects;
        collectionView!.backgroundColor = UIColor(patternImage: UIImage(named: "ProjectBackground")!)
        
        
        
        collectionView!.registerClass(ProjectCell.self, forCellWithReuseIdentifier: PhotoCellIdentifier)
        collectionView?.dataSource = self;
        collectionView?.delegate = self
        
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.projects.count;
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var photoCell:ProjectCell  =
            collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellIdentifier,forIndexPath:indexPath) as ProjectCell;
        var project : Project = projects[indexPath.item]
        photoCell.imageView!.image = project.captionImage()
       
        
        return photoCell;
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        var project : Project = projects[indexPath.item]
        delegate?.projectSelectionChanged(project)
        
    }
    

}

class ProjectCell: UICollectionViewCell
{
    
    var imageView:UIImageView?
    var layoutInfo:NSDictionary?;
    var imageLayer:CALayer?
    
    func customShadowPathForRect(rect:CGRect) -> CGPathRef
    {
        let kCurveSlope:CGFloat = 4;
        
        var shadowPath: UIBezierPath  = UIBezierPath()
        var startX:CGFloat = CGRectGetMinX(rect);
        var startY:CGFloat = CGRectGetMinY(rect) + rect.size.height * 0.4;
        
        shadowPath.moveToPoint(CGPointMake(startX,startY))
        shadowPath.addLineToPoint(CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) + kCurveSlope));
        shadowPath.addQuadCurveToPoint(CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) + kCurveSlope), controlPoint: CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect) - kCurveSlope))
        
        var stopX:CGFloat = CGRectGetMaxX(rect);
        var stopY:CGFloat = CGRectGetMinY(rect) + rect.size.height * 0.4;
        
        shadowPath.addLineToPoint(CGPointMake(stopX,stopY))
        shadowPath.closePath()
        
        return shadowPath.CGPath;
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.layer.shadowOpacity = 0.5;
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.shouldRasterize = true;
        self.layer.shadowPath = self.customShadowPathForRect(self.bounds)
        
        var imageRect = CGRectInset(self.bounds, 10.0, 20.0)
        imageRect.origin.y += 10.0;
        
        self.imageView = UIImageView(frame: imageRect)
        self.imageView!.contentMode = .ScaleAspectFill;
        self.imageView!.clipsToBounds = true;
        self.contentView.addSubview(self.imageView!)

        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse(){
        
        super.prepareForReuse()
        self.imageView!.image = nil;
    }
    
   
    
}