//
//  DBManager.m
//  PicFlow++
//
//  Created by Sheen on 3/25/15.
//  Copyright (c) 2015 Sheen. All rights reserved.


#import "DBManager.h"
#import "Utilities.h"
#import "PicFlow-Swift.h"


static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface DBManager()
-(BOOL)createDB;
-(BOOL)executeQuery:(NSString*)query;
-(const char*)createTabelQuery;
-(Project*)projectFromStatement;
-(Project*)projectForId:(NSString*)projectId;
-(BOOL)updateProject:(Project*)project;
-(Project*)projectForQuery:(NSString*)querySQL;
-(NSString*)projectedIdForCreationDate:(NSDate*)creationDate;
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
    
    NSString  *docsDir = [Utilities documentDir];//dirPaths[0];
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

-(BOOL)updateProject:(Project*)project
{
    NSString *updateQuery = [NSString stringWithFormat:@"update projectsDetail SET projectName = \"%@\",resourcePath = \"%@\",captionImagePath = \"%@\",modificationDate = \"%@\" where projectId = \"%@\"",project.name,project.resourcePath,project.captionImagePath,[Utilities convertDateToString:project.modificationDate],project.uniqueId];
    
    return [self executeQuery:updateQuery];
}

-(BOOL)saveProject:(Project*)project
{
    BOOL status = NO;
    
    if(project.uniqueId)
    {
        status = [self updateProject:project];
    }
    else
    {
        //save project
        NSString *insertQuery = [NSString stringWithFormat:@"insert into projectsDetail (projectName,resourcePath,captionImagePath,creationDate) values (\"%@\",\"%@\",\"%@\",\"%@\")",project.name,project.resourcePath,project.captionImagePath,[Utilities convertDateToString:project.creationDate]];
        status = [self executeQuery:insertQuery];
        if(status)
        {
            project.uniqueId = [self projectedIdForCreationDate:project.creationDate];
        }
    }
    
    return status;
}

-(NSString*)projectedIdForCreationDate:(NSDate*)creationDate
{
    NSString *querySQL = [NSString stringWithFormat:
                          @"select * from projectsDetail where creationDate = \"%@\"",[Utilities convertDateToString:creationDate]];
   
    Project *project = [self projectForQuery:querySQL];
    return project.uniqueId;
}

-(Project*)projectForQuery:(NSString*)querySQL
{
    Project *returnProject = nil;
    if ([self prepareStatement:querySQL])
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            returnProject = [self projectFromStatement];
        }
        
        sqlite3_reset(statement);
    }
    
    return returnProject;

}


-(Project*)projectForId:(NSString*)projectId
{
    NSString *querySQL = [NSString stringWithFormat:
                          @"select * from projectsDetail where projectId = \"%@\"",projectId];
    return [self projectForQuery:querySQL];
}

-(Project*)projectFromStatement
{
    
    Project *newProject = [[Project alloc] init];
    const char *col1Value = (const char *) sqlite3_column_text(statement, 0);
    if(col1Value)
    {
        NSString *projectId = [[NSString alloc] initWithUTF8String:
                           col1Value];
        newProject.uniqueId = projectId;
    }
    
    const char *col2Value = (const char *) sqlite3_column_text(statement, 1);
    if(col2Value)
    {
        NSString *name = [[NSString alloc] initWithUTF8String:
                      col2Value];
        newProject.name = name;
    }
    
    const char *col3Value = (const char *) sqlite3_column_text(statement, 2);
    if(col3Value)
    {
        NSString *rPath = [[NSString alloc] initWithUTF8String:
                      col3Value];
        newProject.resourcePath = rPath;
    }
    
    const char *col4Value = (const char *) sqlite3_column_text(statement, 3);
    if(col4Value)
    {
        NSString *imagePath = [[NSString alloc] initWithUTF8String:
                           col4Value];
        newProject.captionImagePath = imagePath;
    }
    
    const char *col5Value = (const char *) sqlite3_column_text(statement, 4);
    if(col5Value)
    {
        NSString *creationDate = [[NSString alloc] initWithUTF8String:
                              col5Value];
        newProject.creationDate = [Utilities convertStringToDate:creationDate];
    }
    
    const char *col6Value = (const char *) sqlite3_column_text(statement, 5);
    if(col6Value)
    {
        NSString *modificationDate = [[NSString alloc] initWithUTF8String:
                                  col6Value];
        newProject.modificationDate = [Utilities convertStringToDate:modificationDate];
    }
        
    [newProject load];
    
    return newProject;
}


-(BOOL)prepareStatement:(NSString*)querySQL
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            return YES;
        }
    }
    
    return NO;
}


-(NSArray*)getProjects
{
 
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *querySQL = [NSString stringWithFormat:
                              @"select * from projectsDetail"];
    
    if ([self prepareStatement:querySQL])
     {
             while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                [resultArray addObject:[self projectFromStatement]];
            }
    
         sqlite3_reset(statement);
     }
   
    return resultArray;
}


@end
