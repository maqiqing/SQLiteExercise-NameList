//
//  SQLManager.h
//  SQLiteExercise-NameList
//
//  Created by 马头 on 2019/3/7.
//  Copyright © 2019 马头. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "StudentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLManager : NSObject {
    sqlite3 *db;
}

+ (SQLManager *)shareManager;

// 查询所有
- (NSArray<StudentModel *> *)selectAllData;

// 根据 id 查询
- (StudentModel *)searchWithIdNum:(StudentModel *)model;

// 插入
- (int)insert:(StudentModel *)model;

// 删除
- (void)remove:(StudentModel *)model;

// 修改
- (void)modify:(StudentModel *)model;

@end

NS_ASSUME_NONNULL_END
