//
//  GestureDemoViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "GestureDemoViewController.h"
#import "CustomHitTestView.h"

@interface GestureDemoViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UILabel *logLabel;
@property (nonatomic, strong) NSMutableString *logText;

@end

@implementation GestureDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"事件处理演示";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logText = [NSMutableString string];
    [self setupScrollView];
    [self setupHitTestDemo];
    [self setupGestureDemo];
    [self setupGestureConflictDemo];
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 1500);
    [self.view addSubview:self.scrollView];
}

- (void)setupHitTestDemo {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 30)];
    titleLabel.text = @"自定义Hit-Test扩大点击区域";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:titleLabel];
    
    // 普通视图（点击区域小）
    UIView *normalView = [[UIView alloc] initWithFrame:CGRectMake(20, 60, 100, 100)];
    normalView.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *normalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNormalTap:)];
    [normalView addGestureRecognizer:normalTap];
    [self.scrollView addSubview:normalView];
    
    UILabel *normalLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 60, 200, 100)];
    normalLabel.text = @"普通视图（点击区域小）";
    normalLabel.numberOfLines = 0;
    normalLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:normalLabel];
    
    // 自定义Hit-Test视图（点击区域大）
    CustomHitTestView *customView = [[CustomHitTestView alloc] initWithFrame:CGRectMake(20, 180, 100, 100)];
    customView.backgroundColor = [UIColor blueColor];
    customView.hitTestExpansion = 30; // 扩大30点
    UITapGestureRecognizer *customTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCustomTap:)];
    [customView addGestureRecognizer:customTap];
    [self.scrollView addSubview:customView];
    
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 180, 200, 100)];
    customLabel.text = @"自定义Hit-Test视图（点击区域扩大30点）";
    customLabel.numberOfLines = 0;
    customLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:customLabel];
}

- (void)setupGestureDemo {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 300, 30)];
    titleLabel.text = @"多种手势识别演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:titleLabel];
    
    // 目标视图
    self.targetView = [[UIView alloc] initWithFrame:CGRectMake(100, 340, 150, 150)];
    self.targetView.backgroundColor = [UIColor systemBlueColor];
    [self.scrollView addSubview:self.targetView];
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    [self.targetView addGestureRecognizer:tap];
    
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.targetView addGestureRecognizer:doubleTap];
    
    // 单击手势只有在双击手势失败时才会识别
    [tap requireGestureRecognizerToFail:doubleTap];
    
    // 拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.targetView addGestureRecognizer:pan];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.targetView addGestureRecognizer:pinch];
    
    // 旋转手势
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotation.delegate = self;
    [self.targetView addGestureRecognizer:rotation];
    
    // 日志Label
    self.logLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 510, 335, 200)];
    self.logLabel.numberOfLines = 0;
    self.logLabel.font = [UIFont systemFontOfSize:12];
    self.logLabel.backgroundColor = [UIColor lightGrayColor];
    self.logLabel.text = @"手势日志将显示在这里";
    [self.scrollView addSubview:self.logLabel];
}

- (void)setupGestureConflictDemo {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 730, 300, 30)];
    titleLabel.text = @"手势冲突解决演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:titleLabel];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 770, 335, 100)];
    infoLabel.text = @"上面的视图同时支持缩放和旋转手势，通过代理方法允许同时识别。";
    infoLabel.numberOfLines = 0;
    infoLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:infoLabel];
}

- (void)log:(NSString *)message {
    [self.logText appendFormat:@"%@\n", message];
    self.logLabel.text = self.logText;
    NSLog(@"%@", message);
}

#pragma mark - Gesture Handlers

- (void)handleNormalTap:(UITapGestureRecognizer *)gesture {
    [self log:@"普通视图被点击"];
}

- (void)handleCustomTap:(UITapGestureRecognizer *)gesture {
    [self log:@"自定义Hit-Test视图被点击（点击区域扩大）"];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self log:@"单击手势"];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    [self log:@"双击手势"];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.scrollView];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self log:@"拖动手势开始"];
            break;
        case UIGestureRecognizerStateChanged:
            self.targetView.center = CGPointMake(self.targetView.center.x + translation.x,
                                                self.targetView.center.y + translation.y);
            [gesture setTranslation:CGPointZero inView:self.scrollView];
            break;
        case UIGestureRecognizerStateEnded:
            [self log:@"拖动手势结束"];
            break;
        default:
            break;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = gesture.scale;
        self.targetView.transform = CGAffineTransformScale(self.targetView.transform, scale, scale);
        gesture.scale = 1.0;
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat rotation = gesture.rotation;
        self.targetView.transform = CGAffineTransformRotate(self.targetView.transform, rotation);
        gesture.rotation = 0;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 允许缩放和旋转手势同时识别
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] &&
        [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        return YES;
    }
    if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] &&
        [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
