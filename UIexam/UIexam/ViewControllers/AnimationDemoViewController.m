//
//  AnimationDemoViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "AnimationDemoViewController.h"

@interface AnimationDemoViewController ()

@property (nonatomic, strong) UIView *animatedView;
@property (nonatomic, strong) UIButton *fadeButton;
@property (nonatomic, strong) UIButton *scaleButton;
@property (nonatomic, strong) UIButton *rotationButton;
@property (nonatomic, strong) UIButton *springButton;
@property (nonatomic, strong) UIButton *coreAnimationButton;

@end

@implementation AnimationDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"动画系统示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
}

- (void)setupSubviews {
    // 创建动画视图
    self.animatedView = [[UIView alloc] initWithFrame:CGRectMake(150, 200, 100, 100)];
    self.animatedView.backgroundColor = [UIColor systemBlueColor];
    [self.view addSubview:self.animatedView];
    
    // 创建按钮
    CGFloat buttonWidth = 120;
    CGFloat buttonHeight = 44;
    CGFloat spacing = 20;
    CGFloat startY = 400;
    
    self.fadeButton = [self createButtonWithTitle:@"淡入淡出" frame:CGRectMake(20, startY, buttonWidth, buttonHeight)];
    [self.fadeButton addTarget:self action:@selector(fadeAnimation) forControlEvents:UIControlEventTouchUpInside];
    
    self.scaleButton = [self createButtonWithTitle:@"缩放" frame:CGRectMake(20 + buttonWidth + spacing, startY, buttonWidth, buttonHeight)];
    [self.scaleButton addTarget:self action:@selector(scaleAnimation) forControlEvents:UIControlEventTouchUpInside];
    
    self.rotationButton = [self createButtonWithTitle:@"旋转" frame:CGRectMake(20, startY + buttonHeight + spacing, buttonWidth, buttonHeight)];
    [self.rotationButton addTarget:self action:@selector(rotationAnimation) forControlEvents:UIControlEventTouchUpInside];
    
    self.springButton = [self createButtonWithTitle:@"Spring" frame:CGRectMake(20 + buttonWidth + spacing, startY + buttonHeight + spacing, buttonWidth, buttonHeight)];
    [self.springButton addTarget:self action:@selector(springAnimation) forControlEvents:UIControlEventTouchUpInside];
    
    self.coreAnimationButton = [self createButtonWithTitle:@"Core Animation" frame:CGRectMake(20, startY + (buttonHeight + spacing) * 2, buttonWidth * 2 + spacing, buttonHeight)];
    [self.coreAnimationButton addTarget:self action:@selector(coreAnimationDemo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.fadeButton];
    [self.view addSubview:self.scaleButton];
    [self.view addSubview:self.rotationButton];
    [self.view addSubview:self.springButton];
    [self.view addSubview:self.coreAnimationButton];
}

- (UIButton *)createButtonWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor systemGray5Color];
    button.layer.cornerRadius = 8;
    return button;
}

#pragma mark - UIView Animation

- (void)fadeAnimation {
    // 淡入淡出动画
    [UIView animateWithDuration:0.5 animations:^{
        self.animatedView.alpha = self.animatedView.alpha == 1.0 ? 0.3 : 1.0;
    }];
}

- (void)scaleAnimation {
    // 缩放动画
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat scale = self.animatedView.transform.a == 1.0 ? 1.5 : 1.0;
        self.animatedView.transform = CGAffineTransformMakeScale(scale, scale);
    }];
}

- (void)rotationAnimation {
    // 旋转动画
    [UIView animateWithDuration:0.5 animations:^{
        self.animatedView.transform = CGAffineTransformRotate(self.animatedView.transform, M_PI / 2);
    }];
}

- (void)springAnimation {
    // Spring动画
    [UIView animateWithDuration:0.6
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
        self.animatedView.center = CGPointMake(arc4random() % 300 + 50, arc4random() % 300 + 150);
    } completion:nil];
}

#pragma mark - Core Animation

- (void)coreAnimationDemo {
    // 重置transform
    self.animatedView.transform = CGAffineTransformIdentity;
    
    // 创建动画组
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(1.5);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = @(M_PI * 2);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.5);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scaleAnimation, rotationAnimation, opacityAnimation];
    group.duration = 1.0;
    group.repeatCount = 1;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    [self.animatedView.layer addAnimation:group forKey:@"groupAnimation"];
    
    // 动画结束后恢复
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.animatedView.layer.opacity = 1.0;
        self.animatedView.transform = CGAffineTransformIdentity;
    });
}

@end
