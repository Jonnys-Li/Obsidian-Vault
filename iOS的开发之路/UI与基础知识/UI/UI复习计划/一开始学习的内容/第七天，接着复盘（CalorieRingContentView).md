依旧是先来一段interface接口声明
```objc
@interface CalorieRingContentView()
@property(nonatomic,strong,readwrite)UILabel *caloriesLabel;
``
//到这里你发现不对劲啊，为什么strong就是可读可写了，还要声明readwrite？
//-> 其实这就是开发者的小巧思，因为Public Header（.h)文件里，这个标签会被声明为readonly，让他不被外轻易更改，而对应的在.m文件里，他就被readwrite重新声明，允许被内部赋值，这种封装方法相当高明
@property(nonatomic,strong.readwrite)UILabel*kcalLeftLabel;
//左右箭头
@property(nonatomic,strong)UIImageView *syncIcon;
@property(nonatomic,strong)UIImageView *pencilIcon;

//加载容器视图
@property (nonatomic,strong)UIView *containerView;
@end
```
为什么需要containerView？
你圆环都放容器里了，最好的做法肯定是吧这些有的没有的都塞到这个view里啊，这样的话只需要动一个view就可以吧所有 的这些元素都弄好。
好嘞接下来就是implementation
```objc
@implementation CalorieRingContentView
//初始化ContentView的框架，最牛的是，frame传过去的一般都是内切正方形，不太可能碰到圆环的边缘。
-(instancetype)initWithFrame:(CGRect)frame{
self.[super initWithFrame:frame];
if(self){
[self setupUI];

}
return self;
}

-(void)setuoUI{
self.backgroundColor=[UIColor clearColor];
//1.初始化容器视图
self.containerView=[[UIView alloc]init];
self.containerView.translatesAutoresizingMaskIntoConstraints=NO;
[self addSubview:self.contanerView];
//2.初始化子控件并添加到congtainerView
self.synIcon=[[UIIMageView alloc]initWithImage:[UIImage systemImageNamed:"@arrow.left.arrow.right"]];
self.synIcon.tintColor=[UIColor lightGrayColor];
self.synIcon.contentMode=UIViewCOntentModeSacaleAspectFit;
self.synIcon.translatesAturesizingMaskIntoConstraints=NO;
[self.containerView addSubview:self.synIcon];
self.caloriesLabel=[[UILabel alloc]init];
self.caloriesLabel.font=[UIFont systemFontOfSize:48 weight:UIFOntWeightBold];
self..caloriesLabel.textAlignment=NSTextAlignmentCenter;
self.caloriesLabel.text=@"1720";
self.caloriesLabel.translatesAutoesizingMaskIntoConstrants=NO;
[self.containerView addSubView:self.caloriesLabel];
self.kacalLeftLabel=[[UILabel alloc]init];
self.kacalLeftLabel.font=[UIFont systemFontOfSize:16];
self.kcalLeftLabel.textColor=[UIcolor grayColor];
self.kcalLeftLabel.text=@"kcal left";
self.kcalLeftLabel.translatesAutoresizingMaskIntoConstraints=NO;
[self.containerView addSubView:self.kcalLeftLabel];

self.pencilIcon=[[UIImageView alloc]initWithImage:]UIImage systemImageNamed:@"pencil"]];
self.pencilIcon.tintColor=[UIColor lightgrayColor];
self.pencilIcon.contentMode=UIViewContentMoodeSacleAspectFit;
self.pencilIcon.translatesAutoresizingMaskIntoConstraints=NO;
[self.containerView addSubview:self.pencilIcon];


[self setupConstraints];
}
```
这段代码很长，只说核心的内容：
1. 为什么要用containerView？不用行不行
- containerView是为了更好的代码简介度和完整性，把所有的代码都加入containerView里而不是堆放在self里，这样在你写约束的时候就可以保证一次调整全部应用，不用一个一个的调整
2. 为什么不放在CireclRing的那个container里
- 第一是容易让calorieRingView的代码变得特别臃肿，而且会有迁一发动全身的风险，因为如果你想要调整那个图像中的圆环的布局，就需要动整个代码，代码要副用性好，功能隔离
1. `translatesAutoresizingMaskIntoConstraints=NO;` 代码这么长，啥意思啊
- 其实它就是我们的重要嘉宾，他告诉系统“我要用AutoLayout约束决定大小位置，基于Frame的自动拉伸机制给我关了！“