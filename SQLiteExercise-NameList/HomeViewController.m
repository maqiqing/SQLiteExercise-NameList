//
//  HomeViewController.m
//  SQLiteExercise-NameList
//
//  Created by 马头 on 2019/3/7.
//  Copyright © 2019 马头. All rights reserved.
//

#import "HomeViewController.h"
#import "StudentModel.h"
#import "SQLManager.h"
#import "AddViewController.h"

@interface HomeViewController ()

@property (strong ,nonatomic)NSMutableArray *studentsArray;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60.f;
    self.tableView.tableFooterView = [UIView new];
    [self fetchAllData];
    [self addRefreshAction];
}

- (void)addRefreshAction {
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [self.refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshControlAction {
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"加载中"];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self fetchAllData];
        });
    }
}

- (void)fetchAllData {
    [self.studentsArray removeAllObjects];
    for (StudentModel *model in [[SQLManager shareManager] selectAllData]) {
        [_studentsArray addObject:model];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell" forIndexPath:indexPath];
    
    if (self.studentsArray.count > 0) {
        StudentModel *model = self.studentsArray[indexPath.row];
        cell.textLabel.text = model.idNum;
        cell.detailTextLabel.text = model.name;
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        StudentModel *model = self.studentsArray[indexPath.row];
        [[SQLManager shareManager]remove:model];
        [self fetchAllData];
    }];
    return [NSArray arrayWithObjects:delete, nil];
}

- (IBAction)addUserDone:(UIStoryboardSegue *)sender {
    [self fetchAllData];
}

- (NSMutableArray *)studentsArray {
    if (_studentsArray == nil) {
        _studentsArray = [NSMutableArray array];
    }
    return _studentsArray;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"modifyUser"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StudentModel *model = self.studentsArray[indexPath.row];
        
        AddViewController *vc = segue.destinationViewController;
        vc.isModify = YES;
        vc.model = model;
        
    }
}

@end
