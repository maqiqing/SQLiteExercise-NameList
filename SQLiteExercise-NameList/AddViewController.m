//
//  AddViewController.m
//  SQLiteExercise-NameList
//
//  Created by 马头 on 2019/3/7.
//  Copyright © 2019 马头. All rights reserved.
//

#import "AddViewController.h"
#import "SQLManager.h"
@interface AddViewController ()

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_isModify) {
        self.idNumTextField.text = self.model.idNum;
        self.nameTextField.text = self.model.name;
        self.idNumTextField.userInteractionEnabled = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddUser"]) {
        
        StudentModel *model = [[StudentModel alloc]init];
        model.idNum = self.idNumTextField.text;
        model.name = self.nameTextField.text;
        if (!_isModify) {
            // 写入数据库
            [[SQLManager shareManager]insert:model];
        } else {
            // 修改
            [[SQLManager shareManager]modify:model];
        }
        
    }
}

@end
