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
    var uniqueId:NSString?
    var name:NSString = "";
    var frames:[Frame] = []
    var duration:NSRange?
    var creationDate:NSDate?
    var modificationDate:NSDate?
    var resourcePath:String?
    var captionImagePath:String?
    var projectSaver:ProjectSaver?
    
    
    func cleanUp() -> Void
    {
        //delete resource path
        NSFileManager.defaultManager().removeItemAtPath(resourcePath!, error: nil);
    }
    
    func plistPath() -> String
    {
        var plistPath:String = resourcePath!.stringByAppendingPathComponent("details.plist")
        
        if NSFileManager.defaultManager().fileExistsAtPath(plistPath) == false {
            NSFileManager.defaultManager().createFileAtPath(plistPath, contents: nil, attributes: nil)
        }
        
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
            var _frames: AnyObject? = projectSaver?.getValue("frames")
            if(_frames != nil)
            {
                frames = _frames as [Frame]
                var _frame:Frame?
                for _frame in self.frames
                {
                    _frame.parentFolder = resourcePath!
                }
            }
            
        }
    }
    
    
    func saveToPlist(){
        projectSaver?.saveValue(frames, forKey: "frames")
    }
    
    
    func saveProject(){
        
        self.modificationDate = NSDate(timeIntervalSinceNow: 0)
        DBManager.getSharedInstance().saveProject(self)
        //save the project details to the plist
        saveToPlist()
    }
    
    func setCaptionImage(){
        
        if(frames.count > 0)
        {
            var firstFrame:Frame = frames[0]
            captionImagePath = self.resourcePath!.stringByAppendingPathComponent(firstFrame.imagePath!)
        }
    }
    
    func captionImage() -> UIImage
    {
        var returnImage:UIImage?
        
        if(captionImagePath != nil)
        {
            returnImage = UIImage(contentsOfFile: captionImagePath!)
        }
        
        return returnImage!
    }
    
    func addPhotos(images:NSArray)
    {
        
            if(self.resourcePath == nil)
            {
                self.createResources();
            }
            
            var dict:NSDictionary?
            var image:UIImage?
            
            for dict in images
            {
                var prefix:String = "image"
                var path = NSFileManager.defaultManager().uniqueNameForPath(self.resourcePath!, withPrefix:prefix , withExtension: "png")
                image = dict.objectForKey(UIImagePickerControllerOriginalImage) as? UIImage
                UIImagePNGRepresentation(image).writeToFile(path, atomically: true)
                
                //Here we saving image to our directory
                var newFrame = Frame()
                newFrame.parentFolder = self.resourcePath!
                newFrame.imagePath = path.lastPathComponent
                self.frames.append(newFrame)
            }
            
            if(self.captionImagePath == nil){
                self.setCaptionImage()
                self.saveProject()
            }
            else{
                self.saveToPlist()
            }
         
    }
    
    func checkIndexAndSave(index:NSInteger) -> Void
    {
        if(index == 0 ){
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
       
        var index:NSInteger = 0
        if(endIndex == 0 || startIndex == 0 ){
            index = 0;
        }
        else{
            index = 1;
        }
        
        self.checkIndexAndSave(index);
    }
    
    
    func exportToMovie()
    {
        
        
        
    }
    
    func removeFrame(frame:Frame) -> Bool
    {
        var returnValue:Bool = false
        var index = find(frames, frame)
        if(index >= 0){
            frames.removeAtIndex(index!);
            returnValue = true
            self.checkIndexAndSave(index!);
        }
        
        return returnValue;
    }
    
}