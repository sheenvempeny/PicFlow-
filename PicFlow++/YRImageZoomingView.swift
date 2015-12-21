//
//  YRImageZoomingView.swift
//  PicFlow++
//
//  Created by Sheen on 3/12/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
import UIKit

class YRImageZoomingView: UIScrollView,UIScrollViewDelegate {
    
    
    var imageView:UIImageView?
    var image:UIImage!
        {
        didSet{
           self.imageView?.frame = self.bounds
           self.imageView?.image = self.image 
        }
    }
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.setupImageView()
    }
    
    
    func setupImageView()
    {
        self.delegate = self
        self.imageView = UIImageView(frame:self.bounds)
        self.imageView!.contentMode = .ScaleAspectFill //ScaleAspectFill
        self.addSubview(self.imageView!)
        self.imageView!.clipsToBounds = true;
        self.showsHorizontalScrollIndicator = true
        self.showsVerticalScrollIndicator = true
        self.backgroundColor = UIColor.clearColor()
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 3;
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapped:")
        doubleTap.numberOfTapsRequired = 2;
        self.addGestureRecognizer(doubleTap);

    }
    
    
    required init?(coder aDecoder: NSCoder) {
       // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.setupImageView()
    }
    
    func doubleTapped(sender:UITapGestureRecognizer)
    {
        if self.zoomScale > 1.0
        {
            self.setZoomScale(1.0, animated:true);
        }
        else
        {
            let point = sender.locationInView(self);
            self.zoomToRect(CGRectMake(point.x-50, point.y-50, 100, 100), animated:true)
        }
        
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!)->UIView
    {
        return self.imageView!
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
       // self.imageView!.setImage(self.imageURL,placeHolder:placeHolder)
        self.imageView?.image = self.image
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
    // Drawing code
    }
    */
    
}