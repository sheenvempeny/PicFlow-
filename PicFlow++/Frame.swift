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
    
    func duration() -> NSInteger
    {
        return 3;
    }
}