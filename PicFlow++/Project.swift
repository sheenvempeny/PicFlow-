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
    var uniqueId:String?
    var name:String = "";
    var frames:[Frame] = []
    var duration:NSRange?
    var creationDate:NSDate?
    var modificationDate:NSDate?
    var resourcePath:String?
    var captionImagePath:String?
    var projectSaver:ProjectSaver?
    
    
    func plistPath() -> String
    {
        var plistPath:String = resourcePath!.stringByAppendingPathComponent("details.plist")
        NSFileManager.defaultManager().createFileAtPath(plistPath, contents: nil, attributes: nil)
        return plistPath
    }
    
    override init() {
        super.init();
    }
    
    func createResources(){
        
        // we will create resource folder with time stamp
        var date:NSDate = NSDate(timeIntervalSinceNow: 0)
        var resourceFolderName:String = Utilities.convertDateToString(date)
        resourcePath = Utilities.documentDir().stringByAppendingPathComponent(resourceFolderName)
        NSFileManager.defaultManager().createDirectoryAtPath(resourcePath!, withIntermediateDirectories: false, attributes: nil, error: nil)
        // Now we will create plist for saving project details
        projectSaver = ProjectSaver(path: self.plistPath())
    }
    
    func load(){
       
        if(projectSaver == nil)
        {
            projectSaver = ProjectSaver(path: self.plistPath())
            frames = projectSaver?.getValue("frames") as [Frame]
        }
    }
    
    
    func saveToPlist(){
        projectSaver?.saveValue(frames, forKey: "frames")
    }
    
    
    func saveProject(){
      DBManager.getSharedInstance().saveProject(self)
      //save the project details to the plist
      saveToPlist()
    }
    
    func setCaptionImage(){
        
        if(frames.count > 0)
        {
            var firstFrame:Frame = frames[0]
            captionImagePath = firstFrame.imagePath
        }
    }
    
    func addPhotos(images:NSArray)
    {
        if(resourcePath == nil)
        {
            createResources();
        }
        
        var dict:NSDictionary?
        var image:UIImage?
    
        for dict in images
        {
            var prefix:NSString = "image" as NSString
            var path:String = Utilities.findaNameToSave(prefix)!
            image = dict.objectForKey(UIImagePickerControllerOriginalImage) as? UIImage
            UIImagePNGRepresentation(image).writeToFile(path, atomically: true)
            
            //Here we saving image to our directory
            var newFrame = Frame()
            newFrame.imagePath = path
            frames.append(newFrame)
        }
        
        if(self.captionImagePath == nil){
            setCaptionImage()
            saveProject()
        }
        else{
            saveToPlist()
        }
        
    }
    
    func repositionFrame(atIndex startIndex:NSInteger,toIndex endIndex:NSInteger) -> Void
    {
        let frame:Frame = frames.removeAtIndex(startIndex)
        frames.insert(frame, atIndex: endIndex)
        saveToPlist()
    }
    
    
    func exportToMovie()
    {
        
        
        
    }
    
}