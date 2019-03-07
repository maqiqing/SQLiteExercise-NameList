//
//  SQLManager.m
//  SQLiteExercise-NameList
//
//  Created by 马头 on 2019/3/7.
//  Copyright © 2019 马头. All rights reserved.
//

#import "SQLManager.h"

@implementation SQLManager

#define kNameFile (@"Student.sqlite")

static SQLManager *manager  = nil;

+ (SQLManager *)shareManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[SQLManager alloc]init];
        // 每次进单例都检测表
        [manager creatDataBaseTableIfNeeded];
    });
    return manager;
}

// 获取 sqlite 路径
- (NSString * )applicationDocumensDirectoryFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:kNameFile];
    return filePath;
}

// 创建或打开数据库
- (void)creatDataBaseTableIfNeeded {
    NSString *writeTablePath = [self applicationDocumensDirectoryFile];
    NSLog(@"数据库的地址是：%@",writeTablePath);
    // 打开数据库
    /*
     参数1 数据库文件所在的完整路径，c语言，要用 UTF8String 转换一下
     参数2 数据库 DataBase 对象
     */
    // SQLITE_OK：代表打开成功
    if (sqlite3_open([writeTablePath UTF8String], &db) != SQLITE_OK) {
        // 失败
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败");// 抛出错误
    } else {
        char *err;
        // 创建语句
        NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS StudentName (idNum TEXT PRIMARY KEY, NAME TEXT);"];
        /*
         参数1 db对象
         参数2 语句
         参数3/4 回调函数/回调函数传递的参数
         参数5 是一个错误信息
         */
        if (sqlite3_exec(db, [createSQL UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            // 失败
            sqlite3_close(db);
            NSAssert(NO, @"建表失败 %s",err);// 抛出错误
        }
        // 打开成功，关闭
        sqlite3_close(db);
    }
}

// 查询所有数据
- (NSArray<StudentModel *> *)selectAllData {
    NSString *path = [self applicationDocumensDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        // 失败
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败");
    } else {
        NSString *sql = @"SELECT * FROM StudentName";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            NSMutableArray *array = [NSMutableArray array];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *idNum = (char *)sqlite3_column_text(statement, 0);
                NSString *idNumString = [NSString stringWithUTF8String:idNum];
                char *name = (char *)sqlite3_column_text(statement, 1);
                NSString *nameString = [NSString stringWithUTF8String:name];
                
                StudentModel *model = [[StudentModel alloc]init];
                model.idNum = idNumString;
                model.name = nameString;
                
                [array addObject:model];
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
            return array;
        }
    }
    return nil;
}

// 查询数据
- (StudentModel *)searchWithIdNum:(StudentModel *)model {
    NSString *path = [self applicationDocumensDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        // 失败
        sqlite3_close(db);
        NSAssert(NO, @"打开数据库失败");
    } else {
        // 查询语句
        NSString *qsql = @"SELECT idNum,name FROM StudentName where idNum = ?";
        sqlite3_stmt *statement; //语句对象
        /*
         参数1 数据库对象
         参数2 SQL语句
         参数3 执行语句的长度 -1表示全部长度
         参数4 语句对象
         参数5 没有执行的j语句部分 NULL
         */
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            // 进行 按主键查询数据库
            NSString *idNum = model.idNum;
            /*
             参数1 语句对象
             参数2 参数开始执行的序号
             参数3 我们要绑定的值
             参数4 绑定的字符串的长度
             参数5 指针 NULL
             */
            sqlite3_bind_text(statement, 1, [idNum UTF8String], -1, NULL);
            
            // 有一个返回值 SQLITE_ROW常量代表查出来了
            if (sqlite3_step(statement) == SQLITE_ROW) {
                // 提取数据
                /*
                 参数1 语句对象 statement
                 参数2 字段的索引 0
                 */
                char *idNum = (char *)sqlite3_column_text(statement, 0);
                // 数据转换
                NSString *idNumString = [NSString stringWithUTF8String:idNum];
                
                char *name = (char *)sqlite3_column_text(statement, 1);
                NSString *nameString = [NSString stringWithUTF8String:name];
                
                StudentModel *model = [[StudentModel alloc]init];
                model.idNum = idNumString;
                model.name = nameString;
                
                sqlite3_finalize(statement);
                sqlite3_close(db);
                
                return  model;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    return nil;
}

// 插入
- (int)insert:(StudentModel *)model {
    NSString *path = [self applicationDocumensDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败");
    } else {
        NSString *sql = @"INSERT OR REPLACE INTO StudentName (idNum, name) VALUES (?, ?)";
        sqlite3_stmt *statement;
        // 预处理过程
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [model.idNum UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [model.name UTF8String], -1, NULL);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSAssert(NO, @"插入数据失败");
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
    }
    return 0;
}

- (void)remove:(StudentModel *)model {
    /*
     第一步 sqlite3_open 打开数据库
     第二步 sqlite3_prepare_v2 预处理 SQL 语句操作
     第三步 sqlite3_bind_text 函数绑定参数
     第四步 sqlite3_step 函数执行 SQL 语句
     第五步 sqlite3_finalize 和 sqlite3_finalize 释放资源
     */

    NSString *path = [self applicationDocumensDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败");
    } else {
        NSString *sql = @"DELETE FROM StudentName WHERE idNum = ?";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [model.idNum UTF8String], -1, NULL);
        }
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSAssert(NO, @"删除数据失败");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
}

- (void)modify:(StudentModel *)model {
    NSString *path = [self applicationDocumensDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败");
    } else {
        NSString *sql = @"UPDATE StudentName SET name = ? WHERE idNum = ?";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [model.name UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [model.idNum UTF8String], -1, NULL);
        }
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSAssert(NO, @"修改数据失败");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
}

@end
