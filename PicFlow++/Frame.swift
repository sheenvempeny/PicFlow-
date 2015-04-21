//
//  Frame.swift
//  PicFlow++
//
//  Created by Sheen on 3/8/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
import UIKit

class Frame:NSObject,NSCoding
{
   
    var duration : CGFloat?
    var transition : CIFilter?
    var imagePath : String?
    var parentFolder:String?
    
    
    override init() {
        super.init()
        // Initialization code
       self.duration = 3
        self.transition = CIFilter(name: "CIDissolveTransition")
    }

    
    func image() -> UIImage
    {
        return UIImage(contentsOfFile: parentFolder!.stringByAppendingPathComponent(imagePath!))!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    
        if let duration = self.duration{
            aCoder.encodeObject(duration, forKey: "duration")
        }
        if let transition = self.transition{
            aCoder.encodeObject(transition, forKey: "transition")
        }
        if let imagePath = self.imagePath{
            aCoder.encodeObject(imagePath, forKey: "imagePath")
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        
        self.duration  = aDecoder.decodeObjectForKey("duration") as? CGFloat
        self.transition = aDecoder.decodeObjectForKey("transition") as? CIFilter
        self.imagePath = aDecoder.decodeObjectForKey("imagePath") as? String
    }
}