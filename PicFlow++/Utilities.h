//
//  Utilities.h
//  PicFlow++
//
//  Created by Sheen on 3/26/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject
{
    
    
}

+(NSString*)convertDateToString:(NSDate*)date;
+(NSDate*)convertStringToDate:(NSString*)dateStr;
+(NSString*)documentDir;

@end



