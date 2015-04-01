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
    NSString *dateString = nil;
    if(date)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateString=[dateFormat stringFromDate:date];
    }
    return dateString;
}

+(NSDate*)convertStringToDate:(NSString*)dateStr
{
    NSDate *returnDate = nil;
    if(dateStr)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        returnDate =[dateFormat dateFromString:dateStr];
    }
    return returnDate;
}

+(NSString*)documentDir
{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];

    return docsDir;
}

+(NSString*)findaNameToSave:(NSString*)prefix
{
    int cnt = 1;
    NSString *returnName = [NSString stringWithFormat:@"%@%d.png",prefix,cnt]; //String(format: "%@%d.png", name,cnt)
    
    while([[NSFileManager defaultManager] fileExistsAtPath:returnName] == YES)
    {
        cnt++;
        returnName = [NSString stringWithFormat:@"%@%d.png",prefix,cnt];
    }
    
    return returnName;
}


@end
