//
//  MoviePlayView.swift
//  PicFlow++
//
//  Created by Sheen on 7/5/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

//This view is designed to put over the collection view, when user press the preview button

import Foundation


class MoviePlayView : UIView {
    
    var frameWidth:CGFloat?
    var numOfFrames:Int?
    var totalDuration:CGFloat?
    var currentPosition:CGFloat?
    
    
}


protocol MoviePlayViewDelegate {
    
    func numberOfFrames() -> Int
    func widthOfFrame() -> CGFloat
    func totalDuration() -> CGFloat
    func durationAtIndex(index:NSIndexPath) -> CGFloat
    
    
}


protocol MoviePlayActionDelegate{
    
    func movieCurrentTimeChanged(time:CGFloat);
    
    
}