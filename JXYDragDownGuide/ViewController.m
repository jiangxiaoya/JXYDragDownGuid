//
//  ViewController.m
//  JXYDragDownGuide
//
//  Created by 蒋小丫 on 2018/11/28.
//  Copyright © 2018年 蒋小丫. All rights reserved.
//

#import "ViewController.h"
#import "JXYGuideController.h"
#import "MJRefresh.h"

static NSString *JXYTableViewCellID = @"JXYTableViewCellID";
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JXYTableViewCellID];
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self performSelector:@selector(showGuide) withObject:nil afterDelay:1.0];
    
}

- (void)refresh {
    [self performSelector:@selector(endRefresh) withObject:nil afterDelay:1.0];
}
- (void)endRefresh {
    [self.tableView.mj_header endRefreshing];
}

- (void)showGuide {
    JXYGuideController *vc = [[JXYGuideController alloc] init];
    vc.closeDone = ^{
        [self.tableView.mj_header beginRefreshing];
    };
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}


#pragma mark -
#pragma mark - UITableViewDelegate,UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JXYTableViewCellID forIndexPath:indexPath];
    cell.textLabel.text = @"新手引导";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


@end
