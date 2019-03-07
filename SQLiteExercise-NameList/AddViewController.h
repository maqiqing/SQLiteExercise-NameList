//
//  AddViewController.h
//  SQLiteExercise-NameList
//
//  Created by 马头 on 2019/3/7.
//  Copyright © 2019 马头. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddViewController : UIViewController

@property (assign ,nonatomic)BOOL isModify;
@property (strong ,nonatomic)StudentModel *model;


@property (weak, nonatomic) IBOutlet UITextField *idNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;


@end

NS_ASSUME_NONNULL_END
