//
//  LifecycleDemoViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "LifecycleDemoViewController.h"

@interface LifecycleDemoViewController ()

@property (nonatomic, strong) UILabel *logLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableString *logText;

@end

@implementation LifecycleDemoViewController

- (void)loadView {
    [super loadView];
    [self log:@"loadView"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self log:@"viewDidLoad"];
    
    self.title = @"视图生命周期演示";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logText = [NSMutableString string];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self log:[NSString stringWithFormat:@"viewWillAppear: %d", animated]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self log:[NSString stringWithFormat:@"viewDidAppear: %d", animated]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self log:[NSString stringWithFormat:@"viewWillDisappear: %d", animated]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self log:[NSString stringWithFormat:@"viewDidDisappear: %d", animated]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self log:@"didReceiveMemoryWarning"];
}

- (void)dealloc {
    [self log:@"dealloc"];
}

- (void)setupUI {
    // 创建ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    // 创建日志Label
    self.logLabel = [[UILabel alloc] init];
    self.logLabel.numberOfLines = 0;
    self.logLabel.font = [UIFont systemFontOfSize:14];
    self.logLabel.textColor = [UIColor blackColor];
    self.logLabel.frame = CGRectMake(20, 20, self.view.bounds.size.width - 40, 0);
    [self.scrollView addSubview:self.logLabel];
    
    // 创建按钮
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [pushButton setTitle:@"Push到下一页" forState:UIControlStateNormal];
    pushButton.frame = CGRectMake(100, 400, 200, 44);
    [pushButton addTarget:self action:@selector(pushNext) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:pushButton];
    
    UIButton *presentButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [presentButton setTitle:@"Present模态页面" forState:UIControlStateNormal];
    presentButton.frame = CGRectMake(100, 460, 200, 44);
    [presentButton addTarget:self action:@selector(presentNext) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:presentButton];
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 600);
}

- (void)log:(NSString *)message {
    NSString *logMessage = [NSString stringWithFormat:@"[%@] %@\n", 
                          [NSDate date], message];
    [self.logText appendString:logMessage];
    self.logLabel.text = self.logText;
    
    // 更新Label高度
    CGSize size = [self.logLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width - 40, CGFLOAT_MAX)];
    self.logLabel.frame = CGRectMake(20, 20, size.width, size.height);
    
    // 输出到控制台
    NSLog(@"%@ - %@", NSStringFromClass([self class]), message);
}

- (void)pushNext {
    LifecycleDemoViewController *nextVC = [[LifecycleDemoViewController alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)presentNext {
    LifecycleDemoViewController *nextVC = [[LifecycleDemoViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:nextVC];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                   target:self 
                                                                                   action:@selector(dismiss)];
    nextVC.navigationItem.rightBarButtonItem = closeButton;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
