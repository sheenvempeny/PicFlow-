//
//  DetailViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/10/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
class DetailViewController: UIViewController,RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    var visibleRect:CGRect = CGRectZero
    @IBOutlet weak var imageScrollView: YRImageZoomingView!
   @IBOutlet weak var picCollectionView: UICollectionView!
    
    func getOPViewController() -> OperationViewController
    {
        let mAppDelegate:AppDelegate  =  UIApplication.sharedApplication().delegate as AppDelegate
        return mAppDelegate.mainViewController!.operViewController;
    }


    func getProject() -> Project?
    {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var project:Project? = appDelegate.mainViewController?.selectedProject
        
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
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("selectDefaultPic"), userInfo: nil, repeats: false)
       
    }
    
    func reloadProject()
    {
        self.picCollectionView.reloadData()
    }
    
    
   
    @IBAction func deleteFrame(sender: AnyObject)
    {
        
        
    }

    
    @IBAction func changeDuration(sender: AnyObject)
    {
        
        
        
    }

    @IBAction func back(sender: AnyObject)
    {
        
        
        
    }
    
    @IBAction func showTransitions(sender: AnyObject)
    {
        
        
    }
  
    
    @IBAction func showPhotosList(sender:AnyObject)
    {
        self.getOPViewController().currentViewController = self;
        self.getOPViewController().addPhotos(self)
    }
    
    @IBAction func showMusicList(sender:AnyObject)
    {
        self.getOPViewController().currentViewController = self;
        self.getOPViewController().addMusic(self)
    }
    
    @IBAction func Preview(sender:AnyObject)
    {
        
        
        
        
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
        //self.setupScales()
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func selectDefaultPic()
    {
        if(self.frames()?.count > 0)
        {
            
            var frame:Frame = self.frames()![0]
            imageScrollView?.image = frame.image()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.frames()!.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(120.0, 120.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0.0, 0, 0.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
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
        imageScrollView.image = frame.image()
        
        
    }//Dictionary<String,UIView>

   
}

class FrameCell: UICollectionViewCell
{
    
    private var imageView:UIImageView!
  //  private var deleteButton:UIButton?

    var inFrame:Frame? {
        didSet {
            
            self.imageView?.image = inFrame?.image()
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
