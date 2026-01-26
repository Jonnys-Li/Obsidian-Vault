//
//  MultiTypeCellViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "MultiTypeCellViewController.h"
#import "CustomTableViewCell.h"
#import "DataModel.h"

@interface MultiTypeCellViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<DataModel *> *dataArray;

@end

@implementation MultiTypeCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"多Type Cell示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTableView];
    [self loadData];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // 注册不同类型的Cell
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"ImageCell"];
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"VideoCell"];
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.view addSubview:self.tableView];
}

- (void)loadData {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 30; i++) {
        DataModel *model = [[DataModel alloc] init];
        model.title = [NSString stringWithFormat:@"标题 %ld", (long)i];
        model.content = [NSString stringWithFormat:@"这是第%ld条内容", (long)i];
        
        // 随机分配不同类型
        NSInteger type = i % 3;
        switch (type) {
            case 0:
                model.cellType = CellTypeText;
                break;
            case 1:
                model.cellType = CellTypeImage;
                break;
            case 2:
                model.cellType = CellTypeVideo;
                break;
        }
        
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
    DataModel *model = self.dataArray[indexPath.row];
    
    // 根据类型返回不同的Cell
    NSString *identifier = [self identifierForCellType:model.cellType];
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    [cell configureWithModel:model];
    
    return cell;
}

- (NSString *)identifierForCellType:(CellType)type {
    switch (type) {
        case CellTypeText:
            return @"TextCell";
        case CellTypeImage:
            return @"ImageCell";
        case CellTypeVideo:
            return @"VideoCell";
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 可以根据不同类型返回不同高度
    DataModel *model = self.dataArray[indexPath.row];
    switch (model.cellType) {
        case CellTypeText:
            return UITableViewAutomaticDimension;
        case CellTypeImage:
            return 150;
        case CellTypeVideo:
            return 200;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DataModel *model = self.dataArray[indexPath.row];
    NSLog(@"点击了类型为%ld的Cell", (long)model.cellType);
}

@end
