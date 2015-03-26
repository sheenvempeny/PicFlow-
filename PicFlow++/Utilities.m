//
//  Utilities.m
//  PicFlow++
//
//  Created by Sheen on 3/26/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+(NSString*)convertDateToString:(NSDate*)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormat stringFromDate:date];
    return dateString;
}

+(NSDate*)convertStringToDate:(char*)dateStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *returnDate =[dateFormat dateFromString:[NSString stringWithUTF8String:dateStr]];

    return returnDate;
}


@end
