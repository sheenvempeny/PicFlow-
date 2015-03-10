//
//  DetailViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/10/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
class DetailViewController: UIViewController,RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    
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
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.picCollectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return CGSizeMake(130.0, 170.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 20.0, 0, 20.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20.0
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
        return UIEdgeInsetsMake(0, 50, 0, 50)
    }
    
    func scrollSpeedValueInCollectionView(collectionView: UICollectionView) -> CGFloat {
        return 15.0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        var frame:Frame = self.frames()![indexPath.item]
        imageView.image = frame.image
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
        self.imageView = UIImageView(frame: self.bounds)
        self.imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.contentView.addSubview(imageView)
    }
}
