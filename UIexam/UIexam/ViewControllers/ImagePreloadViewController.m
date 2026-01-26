//
//  ImagePreloadViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "ImagePreloadViewController.h"
#import "CustomTableViewCell.h"

@interface ImagePreloadViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *imageURLs;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *imageCache;

@end

@implementation ImagePreloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片预加载示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageCache = [NSMutableDictionary dictionary];
    [self setupTableView];
    [self loadData];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"ImageCell"];
    [self.view addSubview:self.tableView];
}

- (void)loadData {
    // 使用占位图片URL（实际项目中应该是真实的图片URL）
    NSMutableArray *urls = [NSMutableArray array];
    for (NSInteger i = 0; i < 50; i++) {
        // 这里使用占位图片服务，实际项目中替换为真实URL
        NSString *url = [NSString stringWithFormat:@"https://picsum.photos/200/200?random=%ld", (long)i];
        [urls addObject:url];
    }
    self.imageURLs = urls;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSString *imageURL = self.imageURLs[indexPath.row];
    
    // 显示占位图
    cell.imageView.image = [UIImage imageNamed:@"placeholder"] ?: [UIImage new];
    
    // 检查缓存
    UIImage *cachedImage = self.imageCache[imageURL];
    if (cachedImage) {
        cell.imageView.image = cachedImage;
    } else {
        // 异步加载图片
        [self loadImageAsync:imageURL forCell:cell];
    }
    
    return cell;
}

- (void)loadImageAsync:(NSString *)imageURL forCell:(CustomTableViewCell *)cell {
    // 在后台线程加载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 模拟网络请求延迟
        [NSThread sleepForTimeInterval:0.1];
        
        // 这里简化处理，实际应该使用NSURLSession下载图片
        // 为了演示，我们创建一个简单的图片
        UIImage *image = [self createPlaceholderImage];
        
        // 在主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // 检查Cell是否还在显示这个图片（避免Cell重用导致图片错乱）
            if ([cell isKindOfClass:[CustomTableViewCell class]]) {
                cell.imageView.image = image;
            }
            // 缓存图片
            self.imageCache[imageURL] = image;
        });
    });
}

- (UIImage *)createPlaceholderImage {
    // 创建一个简单的占位图片
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 200), NO, 0);
    [[UIColor lightGrayColor] setFill];
    UIRectFill(CGRectMake(0, 0, 200, 200));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 预加载当前和后续几个Cell的图片
    NSInteger startIndex = indexPath.row;
    NSInteger endIndex = MIN(startIndex + 3, self.imageURLs.count - 1);
    
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        [self preloadImageAtIndex:i];
    }
}

- (void)preloadImageAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.imageURLs.count) {
        return;
    }
    
    NSString *imageURL = self.imageURLs[index];
    
    // 检查是否已加载
    if (self.imageCache[imageURL]) {
        return;
    }
    
    // 使用低优先级预加载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image = [self createPlaceholderImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageCache[imageURL] = image;
        });
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
