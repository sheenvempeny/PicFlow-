//
//  Frame.swift
//  PicFlow++
//
//  Created by Sheen on 3/8/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
import UIKit

class Frame:NSObject
{
    var image : UIImage?;
    var range: NSRange?
    var transition : CIFilter?
    
    override init() {
        super.init()
        // Initialization code
        self.range = NSMakeRange(0, 3)
        self.transition = CIFilter(name: "CIDissolveTransition")

    }

    func duration() -> NSInteger
    {
        return range!.length;
    }
    
    
}