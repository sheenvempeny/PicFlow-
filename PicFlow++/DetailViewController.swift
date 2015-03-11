//
//  DetailViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/10/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
class DetailViewController: UIViewController,RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var picCollectionView: UICollectionView!

    func getProject() -> Project?
    {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var project:Project? = appDelegate.mainViewController?.mProject
        
        return project;
        
    }
    
    func frames () -> [Frame]?
    {
        return self.getProject()?.frames;
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.picCollectionView.registerClass(FrameCell.self, forCellWithReuseIdentifier: "horizontalCell")
        self.picCollectionView.delegate = self
        self.picCollectionView.dataSource = self
        (self.picCollectionView.collectionViewLayout as RAReorderableLayout).scrollDirection = .Horizontal
        self.setupScrollView();
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.picCollectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated);
    
        // Setup the scrollview scales on viewWillAppear
        self.setupScales()
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.frames()!.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(120.0, 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0.0, 0, 0.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: FrameCell
        cell = self.picCollectionView.dequeueReusableCellWithReuseIdentifier("horizontalCell", forIndexPath: indexPath) as FrameCell
        cell.inFrame = self.frames()![indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        self.getProject()?.repositionFrame(atIndex: atIndexPath.item, toIndex: toIndexPath.item)
        
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 5, 0, 5)
    }
    
    func scrollSpeedValueInCollectionView(collectionView: UICollectionView) -> CGFloat {
        return 15.0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
        var frame:Frame = self.frames()![indexPath.item]
        imageView.image = frame.image
        self.imageView.frame = CGRectMake(0, 0, frame.image!.size.width, frame.image!.size.height)
        // Tell the scroll view the size of the contents
        self.imageScrollView.contentSize = frame.image!.size;
       self.setupScales()
        
    }
    
    func setupScrollView() -> Void
    {
        
        // Sets the scrollview delegate as self
        self.imageScrollView.delegate = self;
        
        // Add doubleTap recognizer to the scrollView
        //  UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        var doubleTapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        self.imageScrollView.addGestureRecognizer(doubleTapRecognizer);
        
        // Add two finger recognizer to the scrollView
        var twoFingerTapRecognizer:UITapGestureRecognizer  = UITapGestureRecognizer(target: self, action: "scrollViewTwoFingerTapped:")
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        self.imageScrollView.addGestureRecognizer(twoFingerTapRecognizer);
        
    }

    func setupScales() {
    // Set up the minimum & maximum zoom scales
        var scrollViewFrame:CGRect = self.imageScrollView.frame;
        var scaleWidth:CGFloat = scrollViewFrame.size.width / self.imageScrollView.contentSize.width;
        var scaleHeight:CGFloat = scrollViewFrame.size.height / self.imageScrollView.contentSize.height;
        var minScale:CGFloat  = min(scaleWidth, scaleHeight);
        self.imageScrollView.minimumZoomScale = minScale;
        self.imageScrollView.maximumZoomScale = 1.0;
        self.imageScrollView.zoomScale = minScale;
        self.centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        // This method centers the scroll view contents also used on did zoom
        var boundsSize:CGSize = self.imageScrollView.bounds.size;
        var contentsFrame:CGRect  = self.imageView.frame;
        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0;
        } else {
            contentsFrame.origin.x = 0.0;
        }
        
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0;
        } else {
            contentsFrame.origin.y = 0.0;
        }
        
        self.imageView.frame = contentsFrame;
    }
    func viewForZoomingInScrollView(scrollView:UIScrollView) -> UIView{
        // Return the view that we want to zoom
        return self.imageView;
    }
    
    func scrollViewDidZoom(scrollView:UIScrollView) {
    // The scroll view has zoomed, so we need to re-center the contents
        self.centerScrollViewContents()
    }
    
    func scrollViewDoubleTapped(recognizer:UITapGestureRecognizer) {
    // Get the location within the image view where we tapped
       var pointInView:CGPoint = recognizer.locationInView(self.imageView)
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
        var newZoomScale:CGFloat = self.imageScrollView.zoomScale * 1.5;
        newZoomScale = min(newZoomScale, self.imageScrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
        var scrollViewSize:CGSize = self.imageScrollView.bounds.size;
    
        var w:CGFloat = scrollViewSize.width / newZoomScale;
        var h:CGFloat = scrollViewSize.height / newZoomScale;
        var x:CGFloat = pointInView.x - (w / 2.0);
        var y:CGFloat = pointInView.y - (h / 2.0);
    
        var rectToZoomTo:CGRect = CGRectMake(x, y, w, h);
        self.imageScrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func scrollViewTwoFingerTapped(recognizer:UITapGestureRecognizer) {
        // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
        var newZoomScale:CGFloat = self.imageScrollView.zoomScale / 1.5;
        newZoomScale = max(newZoomScale, self.imageScrollView.minimumZoomScale);
        self.imageScrollView.setZoomScale(newZoomScale, animated: true)
        
    }

}

class FrameCell: UICollectionViewCell
{
    
    private var imageView:UIImageView!

    var inFrame:Frame? {
        didSet {
            
            self.imageView?.image = inFrame?.image
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       
    }
    
      private func configure() {
        
        let backImageView:UIImageView = UIImageView(frame: self.bounds)
        [self.backgroundView?.removeFromSuperview()]
        self.backgroundView = backImageView
        backImageView.image = UIImage(named: "film.png")
       
        
        var imageRect:CGRect = CGRectMake(5.0, 10.0, CGRectGetWidth(self.bounds) - 10.0, CGRectGetHeight(self.bounds) - 20.0)
        self.imageView = UIImageView(frame: imageRect)
        self.imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.contentView.addSubview(imageView)
    }
}
