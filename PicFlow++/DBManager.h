//
//  DBManager.h
//  PicFlow++
//
//  Created by Sheen on 3/25/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-(BOOL)saveProject:(NSString*)projectName resourcePath:(NSString*)rPath creationDate:(NSDate*)date;
@end