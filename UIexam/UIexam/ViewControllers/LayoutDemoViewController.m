//
//  LayoutDemoViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "LayoutDemoViewController.h"

@interface LayoutDemoViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *frameLayoutView;
@property (nonatomic, strong) UIView *autoLayoutView;
@property (nonatomic, strong) UIButton *switchButton;

@end

@implementation LayoutDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"布局系统演示";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupScrollView];
    [self setupFrameLayout];
    [self setupAutoLayout];
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 1200);
    [self.view addSubview:self.scrollView];
}

- (void)setupFrameLayout {
    // Frame布局示例
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 30)];
    titleLabel.text = @"Frame布局示例";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:titleLabel];
    
    self.frameLayoutView = [[UIView alloc] initWithFrame:CGRectMake(20, 60, 335, 200)];
    self.frameLayoutView.backgroundColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:self.frameLayoutView];
    
    // 红色视图
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    redView.backgroundColor = [UIColor redColor];
    [self.frameLayoutView addSubview:redView];
    
    // 蓝色视图（在红色下方）
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(20, 130, 100, 50)];
    blueView.backgroundColor = [UIColor blueColor];
    [self.frameLayoutView addSubview:blueView];
    
    // 绿色视图（在红色右侧）
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(140, 20, 100, 100)];
    greenView.backgroundColor = [UIColor greenColor];
    [self.frameLayoutView addSubview:greenView];
}

- (void)setupAutoLayout {
    // AutoLayout布局示例
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"AutoLayout布局示例";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:titleLabel];
    
    self.autoLayoutView = [[UIView alloc] init];
    self.autoLayoutView.backgroundColor = [UIColor lightGrayColor];
    self.autoLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.autoLayoutView];
    
    // 红色视图
    UIView *redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor redColor];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.autoLayoutView addSubview:redView];
    
    // 蓝色视图
    UIView *blueView = [[UIView alloc] init];
    blueView.backgroundColor = [UIColor blueColor];
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.autoLayoutView addSubview:blueView];
    
    // 绿色视图
    UIView *greenView = [[UIView alloc] init];
    greenView.backgroundColor = [UIColor greenColor];
    greenView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.autoLayoutView addSubview:greenView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // titleLabel约束
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [titleLabel.topAnchor constraintEqualToAnchor:self.frameLayoutView.bottomAnchor constant:40],
        
        // autoLayoutView约束
        [self.autoLayoutView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [self.autoLayoutView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:20],
        [self.autoLayoutView.widthAnchor constraintEqualToConstant:335],
        [self.autoLayoutView.heightAnchor constraintEqualToConstant:200],
        
        // redView约束
        [redView.leadingAnchor constraintEqualToAnchor:self.autoLayoutView.leadingAnchor constant:20],
        [redView.topAnchor constraintEqualToAnchor:self.autoLayoutView.topAnchor constant:20],
        [redView.widthAnchor constraintEqualToConstant:100],
        [redView.heightAnchor constraintEqualToConstant:100],
        
        // blueView约束（在redView下方）
        [blueView.leadingAnchor constraintEqualToAnchor:redView.leadingAnchor],
        [blueView.topAnchor constraintEqualToAnchor:redView.bottomAnchor constant:10],
        [blueView.widthAnchor constraintEqualToConstant:100],
        [blueView.heightAnchor constraintEqualToConstant:50],
        
        // greenView约束（在redView右侧）
        [greenView.leadingAnchor constraintEqualToAnchor:redView.trailingAnchor constant:20],
        [greenView.topAnchor constraintEqualToAnchor:redView.topAnchor],
        [greenView.widthAnchor constraintEqualToConstant:100],
        [greenView.heightAnchor constraintEqualToConstant:100]
    ]];
}

@end
