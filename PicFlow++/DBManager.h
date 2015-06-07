//
//  DBManager.h
//  PicFlow++
//
//  Created by Sheen on 3/25/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class Project;

@interface DBManager : NSObject
{
    NSString *databasePath;
}


+(DBManager*)getSharedInstance;
-(NSArray*)getProjects;
-(BOOL)saveProject:(Project*)project;
-(BOOL)removeProject:(Project*)project;

@end