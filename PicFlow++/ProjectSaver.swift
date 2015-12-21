//
//  ProjectDetails.swift
//  PicFlow++
//
//  Created by Sheen on 4/2/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation

class ProjectSaver: NSObject {
    
    private
    
    var dict:NSMutableDictionary = NSMutableDictionary()
    var savePath:String?
    
    internal
    
    init(path:String) {
        super.init();
        savePath = path
        if let data =  NSData(contentsOfFile: path)
        {
            if data.length > 0 {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                let _dict = unarchiver.decodeObject() as! NSDictionary
                dict = NSMutableDictionary(dictionary: _dict)
                unarchiver.finishDecoding()
            }
        }

    }
    
    func saveValue(value:AnyObject,forKey key:String)
    {
        dict.setObject(value, forKey: key)
        let data:NSMutableData = NSMutableData()
        let archiver:NSKeyedArchiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(dict)
        archiver.finishEncoding()
        data.writeToFile(savePath!, atomically: true)
        
    }
    
     func getValue(key: String) -> AnyObject? {
        
        return dict.objectForKey(key)
    }
    
}