//
//  DbManager.swift
//  PicFlow++
//
//  Created by Sheen on 3/24/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
import CommonCrypto

private let _SomeManagerSharedInstance = DbManager()


class DbManager: NSObject {
    
    var databasePath:String?
    var  database:sqlite3 //private let database:sqlite3?
    
    class var sharedInstance: DbManager {
        return _SomeManagerSharedInstance
    }
    
    override init() {
        super.init()
        createDB();
    }
    
    func createDB() -> Bool{
        
        var docsDir: String?
        var dirPaths:NSArray?
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        docsDir = dirPaths?.objectAtIndex(0) as? String
        // Build the path to the database file
        databasePath = docsDir?.stringByAppendingPathComponent("projects.db");
        var isSuccess:Bool = true
        var filemgr:NSFileManager = NSFileManager.defaultManager()
        if (filemgr.fileExistsAtPath(databasePath!) == false){
            
            if (sqlite3_open(databasePath, &database) == SQLITE_OK)
            {
                var errMsg;
                var sql_stmt = "create table if not exists studentsDetail(id integer primary key autoincrement, projectName text, resourcePath text)"

                if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                    != SQLITE_OK)
                {
                    isSuccess = false;
                    NSLog("Failed to create table");
                }
                sqlite3_close(database);
                return  isSuccess;
            }
            else {
                isSuccess = false;
                NSLog("Failed to open/create database");
            }
        }    
        return isSuccess;
        
    }
}