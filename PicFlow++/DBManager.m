//
//  DBManager.m
//  PicFlow++
//
//  Created by Sheen on 3/25/15.
//  Copyright (c) 2015 Sheen. All rights reserved.


#import "DBManager.h"
#import "Utilities.h"
#import "PicFlow-Swift.h"

@class Project;


static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface DBManager()
-(BOOL)executeQuery:(NSString*)query;
-(const char*)createTabelQuery;
@end

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(const char*)createTabelQuery
{
    const char *sql_stmt =
    "create table if not exists projectsDetail (projectId integer primary key autoincrement, projectName text, resourcePath text,captionImagePath text,creationDate DATETIME,modifiedDate DATETIME)";
    return sql_stmt;
}

-(BOOL)createDB{
    
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"projects.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = [self createTabelQuery];
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}


-(BOOL)executeQuery:(NSString*)query
{
    
    BOOL status = NO;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = query;
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            status = YES;
        }
        else {
            return status;
        }
        sqlite3_reset(statement);
    }
    
    return status;
}

-(BOOL)saveProject:(NSString*)projectName resourcePath:(NSString*)rPath creationDate:(NSDate*)date
{
    NSString *insertQuery = [NSString stringWithFormat:@"insert into projectsDetail (projectName,resourcePath,creationDate) values (\"%@\",\"%@\",  \"%@\")",projectName,rPath,[Utilities convertDateToString:date]];
    return [self executeQuery:insertQuery];
}

//- (BOOL) saveData:(NSString*)registerNumber name:(NSString*)name
//       department:(NSString*)department year:(NSString*)year;
//{
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into studentsDetail (regno,name, department, year) values (\"%d\",\"%@\", \"%@\", \"%@\")",[registerNumber integerValue],name, department, year];
//                                const char *insert_stmt = [insertSQL UTF8String];
//                                sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//                                if (sqlite3_step(statement) == SQLITE_DONE)
//                                {
//                                    return YES;
//                                }
//                                else {
//                                    return NO;
//                                }
//                                sqlite3_reset(statement);
//                                }
//                                return NO;
//}

//- (NSArray*) findByRegisterNumber:(NSString*)registerNumber
//
//{
//            const char *dbpath = [databasePath UTF8String];
//            if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//            {
//                NSString *querySQL = [NSString stringWithFormat:
//                                      @"select name, department, year from studentsDetail where regno=\"%@\"",registerNumber];
//                const char *query_stmt = [querySQL UTF8String];
//                NSMutableArray *resultArray = [[NSMutableArray alloc]init];
//                if (sqlite3_prepare_v2(database,
//                                       query_stmt, -1, &statement, NULL) == SQLITE_OK)
//                {
//                    if (sqlite3_step(statement) == SQLITE_ROW)
//                    {
//                        NSString *name = [[NSString alloc] initWithUTF8String:
//                                          (const char *) sqlite3_column_text(statement, 0)];
//                        [resultArray addObject:name];
//                        NSString *department = [[NSString alloc] initWithUTF8String:
//                                                (const char *) sqlite3_column_text(statement, 1)];
//                        [resultArray addObject:department];
//                        NSString *year = [[NSString alloc]initWithUTF8String:
//                                          (const char *) sqlite3_column_text(statement, 2)];
//                        [resultArray addObject:year];
//                        return resultArray;
//                    }
//                    else{
//                        NSLog(@"Not found");
//                        return nil;
//                    }
//                    sqlite3_reset(statement);
//                }
//            }
//            return nil;
//        }

@end
