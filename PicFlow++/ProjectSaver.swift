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
    
    var dict:NSMutableDictionary?
    var savePath:String?
    
    internal
    
    init(path:String) {
        super.init();
        savePath = path
        dict = NSMutableDictionary(contentsOfFile: path)
    }
    
    func saveValue(value:AnyObject,forKey key:String)
    {
        dict?.setObject(value, forKey: key)
        dict?.writeToFile(savePath!, atomically: true)
    }
    
     func getValue(key: String) -> AnyObject? {
        
        return dict?.objectForKey(key)
    }
    
}