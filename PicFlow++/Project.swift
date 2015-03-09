//
//  Project.swift
//  PicFlow++
//
//  Created by Sheen on 3/8/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation

class Project : NSObject
{
    var name:String = "";
    var frames:[Frame] = []
    var duration:NSRange?
    
    
    func saveProject(){
    
    }
    
    func addPhotos(images:NSArray){
        NSLog("photos added")
    }
    
}