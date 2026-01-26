//
//  ViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "ViewController.h"
#import "LifecycleDemoViewController.h"
#import "LayoutDemoViewController.h"
#import "RenderDemoViewController.h"
#import "TableViewDemoViewController.h"
#import "ImagePreloadViewController.h"
#import "CollectionViewDemoViewController.h"
#import "MultiTypeCellViewController.h"
#import "AnimationDemoViewController.h"
#import "GestureDemoViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *demoList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UI复习计划";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupDemoList];
    [self setupTableView];
}

- (void)setupDemoList {
    self.demoList = @[
        @{@"title": @"第15天：视图生命周期基础", @"class": [LifecycleDemoViewController class]},
        @{@"title": @"第16-17天：布局系统", @"class": [LayoutDemoViewController class]},
        @{@"title": @"第18天：UIView和CALayer渲染原理", @"class": [RenderDemoViewController class]},
        @{@"title": @"第19-20天：UITableView深入", @"class": [TableViewDemoViewController class]},
        @{@"title": @"第21天：图片预加载与异步解码", @"class": [ImagePreloadViewController class]},
        @{@"title": @"第22天：UICollectionView与自定义Layout", @"class": [CollectionViewDemoViewController class]},
        @{@"title": @"第23天：多Type Cell管理与性能优化", @"class": [MultiTypeCellViewController class]},
        @{@"title": @"第24-25天：动画系统", @"class": [AnimationDemoViewController class]},
        @{@"title": @"第26-27天：事件处理", @"class": [GestureDemoViewController class]}
    ];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *demo = self.demoList[indexPath.row];
    cell.textLabel.text = demo[@"title"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *demo = self.demoList[indexPath.row];
    Class viewControllerClass = demo[@"class"];
    UIViewController *viewController = [[viewControllerClass alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
