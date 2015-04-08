//
//  NSFileManager+Addition.swift
//  PicFlow++
//
//  Created by Sheen on 4/8/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation

extension NSFileManager{
    
    func uniqueNameForPath(location:String, withPrefix prefix:String,withExtension extn:String) -> String
    {
        var returnName:String = ""
        var cnt:Int = 1
        returnName = String(format: "%@/%@%d.%@", location,prefix,cnt,extn)
        
        while(self.fileExistsAtPath(returnName))
        {
            cnt++;
            returnName = String(format: "%@/%@%d.%@", location,prefix,cnt,extn)
            
        }
        
        return returnName;
    }
    
    
}