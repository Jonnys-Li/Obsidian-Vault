//
//  RenderDemoViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "RenderDemoViewController.h"

@interface RenderDemoViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation RenderDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"渲染原理演示";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupScrollView];
    [self setupViewAndLayerDemo];
    [self setupOffscreenRenderingDemo];
    [self setupPerformanceDemo];
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 1500);
    [self.view addSubview:self.scrollView];
}

- (void)setupViewAndLayerDemo {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 30)];
    titleLabel.text = @"UIView和CALayer关系演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:titleLabel];
    
    // UIView示例
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 60, 200, 200)];
    view.backgroundColor = [UIColor blueColor];
    
    // 直接操作CALayer
    view.layer.cornerRadius = 20;
    view.layer.borderWidth = 3;
    view.layer.borderColor = [UIColor redColor].CGColor;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 5);
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 10;
    
    [self.scrollView addSubview:view];
    
    // 添加子Layer
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = CGRectMake(50, 50, 100, 100);
    sublayer.backgroundColor = [UIColor yellowColor].CGColor;
    sublayer.cornerRadius = 10;
    [view.layer addSublayer:sublayer];
}

- (void)setupOffscreenRenderingDemo {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 300, 30)];
    titleLabel.text = @"离屏渲染演示（会触发离屏渲染）";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:titleLabel];
    
    // 1. cornerRadius + masksToBounds（会触发离屏渲染）
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(20, 340, 100, 100)];
    view1.backgroundColor = [UIColor redColor];
    view1.layer.cornerRadius = 20;
    view1.layer.masksToBounds = YES; // 触发离屏渲染
    [self.scrollView addSubview:view1];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(130, 340, 200, 100)];
    label1.text = @"cornerRadius + masksToBounds";
    label1.numberOfLines = 0;
    label1.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:label1];
    
    // 2. shadow（会触发离屏渲染）
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(20, 460, 100, 100)];
    view2.backgroundColor = [UIColor blueColor];
    view2.layer.shadowColor = [UIColor blackColor].CGColor;
    view2.layer.shadowOffset = CGSizeMake(0, 5);
    view2.layer.shadowOpacity = 0.5;
    view2.layer.shadowRadius = 10; // 触发离屏渲染
    [self.scrollView addSubview:view2];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(130, 460, 200, 100)];
    label2.text = @"shadow（使用shadowPath可避免）";
    label2.numberOfLines = 0;
    label2.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:label2];
    
    // 3. shouldRasterize（会触发离屏渲染）
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(20, 580, 100, 100)];
    view3.backgroundColor = [UIColor greenColor];
    view3.layer.shouldRasterize = YES; // 触发离屏渲染
    view3.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.scrollView addSubview:view3];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(130, 580, 200, 100)];
    label3.text = @"shouldRasterize = YES";
    label3.numberOfLines = 0;
    label3.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:label3];
}

- (void)setupPerformanceDemo {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 720, 300, 30)];
    titleLabel.text = @"性能优化演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:titleLabel];
    
    // 使用CALayer代替UIView（不需要交互时）
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(20, 760, 100, 100);
    layer.backgroundColor = [UIColor purpleColor].CGColor;
    layer.cornerRadius = 10;
    [self.scrollView.layer addSublayer:layer];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, 760, 200, 100)];
    label.text = @"使用CALayer代替UIView（不需要交互时性能更好）";
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:label];
    
    // 使用shadowPath避免离屏渲染
    UIView *optimizedView = [[UIView alloc] initWithFrame:CGRectMake(20, 880, 100, 100)];
    optimizedView.backgroundColor = [UIColor orangeColor];
    optimizedView.layer.shadowColor = [UIColor blackColor].CGColor;
    optimizedView.layer.shadowOffset = CGSizeMake(0, 5);
    optimizedView.layer.shadowOpacity = 0.5;
    optimizedView.layer.shadowRadius = 10;
    // 设置shadowPath可以避免离屏渲染
    optimizedView.layer.shadowPath = [UIBezierPath bezierPathWithRect:optimizedView.bounds].CGPath;
    [self.scrollView addSubview:optimizedView];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(130, 880, 200, 100)];
    label2.text = @"使用shadowPath避免离屏渲染";
    label2.numberOfLines = 0;
    label2.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:label2];
}

@end
