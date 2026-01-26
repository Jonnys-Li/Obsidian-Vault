//
//  TableViewDemoViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "TableViewDemoViewController.h"
#import "CustomTableViewCell.h"
#import "DataModel.h"
#import "HeightCache.h"

@interface TableViewDemoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<DataModel *> *dataArray;
@property (nonatomic, strong) HeightCache *heightCache;

@end

@implementation TableViewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UITableView示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.heightCache = [[HeightCache alloc] init];
    [self setupTableView];
    [self loadData];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // 注册Cell
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"CustomCell"];
    
    // 使用自动高度
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.view addSubview:self.tableView];
}

- (void)loadData {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 50; i++) {
        NSString *title = [NSString stringWithFormat:@"标题 %ld", (long)i];
        NSString *content = [NSString stringWithFormat:@"这是第%ld条内容。", (long)i];
        // 随机生成不同长度的内容，用于演示动态高度
        for (NSInteger j = 0; j < arc4random() % 5; j++) {
            content = [content stringByAppendingString:@"这是一段额外的内容，用于测试动态高度计算。"];
        }
        DataModel *model = [DataModel modelWithTitle:title content:content];
        [array addObject:model];
    }
    self.dataArray = array;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    DataModel *model = self.dataArray[indexPath.row];
    [cell configureWithModel:model];
    NSLog(@"使用Cell #%ld 显示第%ld行", (long)cell.cellNumber, (long)indexPath.row);
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cell即将显示，可以在这里预加载数据
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cell已不可见，可以取消加载任务
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 如果使用自动高度，这个方法可以不实现
    // 这里演示高度缓存的使用
    
    // 先从缓存获取
    CGFloat cachedHeight = [self.heightCache heightForIndexPath:indexPath];
    if (cachedHeight > 0) {
        return cachedHeight;
    }
    
    // 计算高度（这里简化处理，实际应该根据内容计算）
    DataModel *model = self.dataArray[indexPath.row];
    CGFloat height = 60 + model.content.length * 0.5; // 简化的计算方式
    
    // 缓存高度
    [self.heightCache cacheHeight:height forIndexPath:indexPath];
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"点击了第%ld行", (long)indexPath.row);
}

@end
