//
//  Project.swift
//  PicFlow++
//
//  Created by Sheen on 3/8/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//



import Foundation

@objc class Project : NSObject
{
    var name:String = "";
    var frames:[Frame] = []
    var duration:NSRange?
    var creationDate:NSDate?
    var modificationDate:NSDate?
    
    
    override init() {
        super.init();
    }
    
    
    func saveProject(){
    
    }
    
    func addPhotos(images:NSArray){
        var dict:NSDictionary?
        var image:UIImage?
    
        for dict in images
        {
            image = dict.objectForKey(UIImagePickerControllerOriginalImage) as? UIImage
            var newFrame = Frame()
            newFrame.image = image;
            newFrame.range = NSMakeRange(frames.count * newFrame.duration(), newFrame.duration())
            frames.append(newFrame)
        }
    }
    
    func repositionFrame(atIndex startIndex:NSInteger,toIndex endIndex:NSInteger) -> Void
    {
        let frame:Frame = frames.removeAtIndex(startIndex)
        frames.insert(frame, atIndex: endIndex)
    }
    
    
    func exportToMovie()
    {
        
        
        
    }
    
}