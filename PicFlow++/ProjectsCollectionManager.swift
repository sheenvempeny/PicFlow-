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



class DeleteViewModal: NSObject {
    
    var timer:NSTimer?
    var delegate:AnyObject?
    
    var indexPath:NSIndexPath?{
        didSet{
        
            timer = NSTimer(timeInterval: 5, target: delegate!, selector: "offDeleteButton:", userInfo: self, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
    }
    
     deinit{
    
        timer!.invalidate();
        
    }
    
}

class ProjectsCollectionManager:NSObject,UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate
{
    
    var collectionView:UICollectionView?
    var projects:[Project] = []
    var PhotoCellIdentifier = "PhotoCell";
    var delegate:ProjectsCollectionProtocol?
    var deleteModals:[DeleteViewModal] = []
    
    init(inCollectionView:UICollectionView, withProjects inProjects:[Project]) {
    
        super.init()
        collectionView = inCollectionView
        projects = inProjects;
        collectionView!.backgroundColor = UIColor(patternImage: UIImage(named: "ProjectsBackground")!)
        
        
        
        collectionView!.registerClass(ProjectCell.self, forCellWithReuseIdentifier: PhotoCellIdentifier)
        collectionView?.dataSource = self;
        collectionView?.delegate = self
        
        //add long press monitor, when long press happens we show delete button
        var lgpr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lgpr.minimumPressDuration = 0.5;
        //lgpr.delegate = self;
        self.collectionView!.addGestureRecognizer(lgpr)
        
        // normal press 
        var ngpr:UITapGestureRecognizer = UITapGestureRecognizer(target: self , action: "handleNormalPress:")
        //ngpr.minimumNumberOfTouches = 1
        ngpr.delegate = self
        self.collectionView!.addGestureRecognizer(ngpr)

        
    }
    
    func offDeleteButton(timer:NSTimer){
        
        var _deleteModal:DeleteViewModal = timer.userInfo as! DeleteViewModal
        var indexPath:NSIndexPath = _deleteModal.indexPath!
        var index = find(self.deleteModals, _deleteModal)
        
        if(index >= 0){
            self.deleteModals.removeAtIndex(index!);
            self.collectionView!.reloadItemsAtIndexPaths(NSArray(object: indexPath) as [AnyObject]);
        }
    
    }
    
    func turnOffAllDeleteButtons() {
        
       deleteModals.removeAll(keepCapacity: false)
       self.collectionView!.reloadData()
    }
    
    func canShowDeleteButton(indexPath:NSIndexPath) -> Bool
    {
        var returnStatus:Bool = false
        var deleteModal:DeleteViewModal?
        for deleteModal in deleteModals{
            if(deleteModal.indexPath!.isEqual(indexPath)){
                returnStatus = true
                break
            }
        }
        
        return returnStatus;
    }
    
    func removeFromDeleteModals(indexPath:NSIndexPath){
        
        var _deleteModal:DeleteViewModal?
        
        for deleteModal in deleteModals{
            if(deleteModal.indexPath!.isEqual(indexPath)){
                var index = find(self.deleteModals, deleteModal)
                self.deleteModals.removeAtIndex(index!);
                return;
            }
        }

        
    }
    
     //# MARK: - HANDLE NORMAL PRESS
    
    func handleNormalPress(gestureRecognizer:UITapGestureRecognizer){
      
        if (gestureRecognizer.state != UIGestureRecognizerState.Ended) {
            return;
        }
        var p:CGPoint = gestureRecognizer.locationInView(self.collectionView!)
        var indexPath:NSIndexPath? = self.collectionView!.indexPathForItemAtPoint(p)

         if (indexPath == nil){
            self.turnOffAllDeleteButtons()
        }
        
    }
    
    //# MARK: - HANDLE LONG PRESS
    
    func handleLongPress(gestureRecognizer:UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizerState.Ended) {
            return;
        }
        var p:CGPoint = gestureRecognizer.locationInView(self.collectionView!)
        var indexPath:NSIndexPath? = self.collectionView!.indexPathForItemAtPoint(p)
        
        if (indexPath != nil){
            
            var deleteViewModal:DeleteViewModal = DeleteViewModal()
            deleteViewModal.delegate = self;
            deleteViewModal.indexPath = indexPath;
            deleteModals.append(deleteViewModal)
            self.collectionView!.reloadItemsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject]);
            
        }
        else
        {
            self.turnOffAllDeleteButtons()
            
        }
    }

     //# MARK: - gestureRecognizer delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        
        return true;
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true;
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        
        if(touch.view is UICollectionView){
            return true;
        }
        
        return false
    }
    
    
    //# MARK: - COLLECTION VIEW DATA SOURCE
    
    
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
            collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellIdentifier,forIndexPath:indexPath) as! ProjectCell;
        var project : Project = projects[indexPath.item]
        photoCell.imageView!.image = project.captionImage()
        photoCell.deleteButton!.hidden = !self.canShowDeleteButton(indexPath)
        
        if(false == photoCell.deleteButton!.hidden){
            photoCell.deleteButton!.addTarget(self, action: "projectDeleted:event:", forControlEvents: UIControlEvents.TouchUpInside);
        }
        
        return photoCell;
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        var project : Project = projects[indexPath.item]
        delegate?.projectSelectionChanged(project)
    }
    
    
    
    func projectDeleted(sender:AnyObject?,event inevent:UIEvent){
        
        var touches:NSSet = inevent.allTouches()!
        var touch:UITouch = touches.anyObject()! as! UITouch
        var touchPoint:CGPoint = touch.locationInView(self.collectionView!)
        var indexPath:NSIndexPath = self.collectionView!.indexPathForItemAtPoint(touchPoint)!
        
        var projectToDelete:Project = projects[indexPath.item]
        if(true == DBManager.getSharedInstance().removeProject(projectToDelete)){
            
            self.removeFromDeleteModals(indexPath)
            projects.removeAtIndex(indexPath.item)
            self.collectionView!.reloadData()
        }
        
    }
    
    

}

class ProjectCell: UICollectionViewCell
{
    
    var imageView:UIImageView?
    var layoutInfo:NSDictionary?;
    var imageLayer:CALayer?
    var deleteButton:UIButton?
    
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
        //adding white shadow around
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.layer.shadowOpacity = 0.5;
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.shouldRasterize = true;
        self.layer.shadowPath = self.customShadowPathForRect(self.bounds)
        
        var imageRect = CGRectInset(self.bounds, 10.0, 20.0)
        imageRect.origin.y += 10.0;
        //add image view
        self.imageView = UIImageView(frame: imageRect)
        self.imageView!.contentMode = .ScaleAspectFill;
        self.imageView!.clipsToBounds = true;
        self.contentView.addSubview(self.imageView!)
        //add a delete button and make it hide on launch
        var buttonHeight = 20.0;
        var buttonWidth = 20.0;
        var buttonPadding = 5.0;
        var deleteButtonFrame = CGRectMake(self.frame.size.width - CGFloat(buttonWidth + buttonPadding),CGFloat(buttonPadding), CGFloat(buttonWidth), CGFloat(buttonHeight));
        self.deleteButton = UIButton(frame: deleteButtonFrame)
        var deleteImage = UIImage(named: "Delete")
        self.deleteButton!.setImage(deleteImage, forState: UIControlState.Normal);
        self.contentView.addSubview(self.deleteButton!)
        self.deleteButton!.hidden = true;
}

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse(){
        
        super.prepareForReuse()
        self.imageView!.image = nil;
    }
    
   
    
}