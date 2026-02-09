## 圆环怎么画？？？
![[Pasted image 20251224174127.png]]
在ios原生库中，没有像半圆环一样的函数库，那我们应该怎么实现这样的需求呢？
	Gemini淡淡一笑：“很简单，我来做不就行了！”
说罢，他直接创建了了一个新的函数CalorieRingView写在外部
![[截屏2025-12-24 17.43.37.png]]
然后怎么办呢？写函数呗
- 首先引用我们的显示函数.h文件
#import "CalorieRingView.h"
- 然后很重要，我们要重新定义角度为弧度！
#define `DEGREES_TO_RADIANS(degrees) ((degrees) * M_PI / 180.0)`
这段代码干啥的呢？
- **`#define`**：预处理指令，在代码编译前，所有的 `DEGREES_TO_RADIANS(x)` 都会被直接替换成后面的数学表达式。
- **`M_PI`**：这是系统自带的一个宏，代表圆周率 $\pi$。
- **括号的作用**：你会发现 `(degrees)` 外面套了很多括号。这是为了防止**运算优先级错误**。例如，如果你传进 `10 + 20`，没有括号就会变成 `10 + 20 * M_PI / 180`，结果就全乱了。
-这个时候我们就把只有人类认识的角度用弧度的形式表示让机器看懂了！
紧接着用
`@interface CalorieRingView ()`
把我们新写的函数定位到storyboard里面（别让他们找不到了）
同时interface作为一个私有接口，我们是不是得往里面送property，得有属性吧
所以：
```objc
@interface CalorieRingView ()
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

  

@end
```

我们可以看到，
- 定义了两个strong属性，为什么是strong？？明明平常都是weak呀？
	哦～原来是因为平常我们都是直接在storyboard里添加控件，控件本身就在被控制器的view强引用，就么有必要用strong了，但是现在，你是自行添加的
	你可没有谁做靠山，所以**自然你自己得自力更生，用strong。**
- CAShapeLayer ? 这是什么玩意儿？？
	与普通的UiView不同，CAShapeLayer 属于Core Animation框架，常常被用来做一些奇特的造型
	就比如圆环的进度条
	然后你定义了`backgroundLayer` 和`progressLayer` 两侧图层，背景层用灰色作为进度条的底色，进度条层用绿色盖在背景层上边。因为CAShapeLayer是直接在GPU上渲染的，因此比drawRect会更省电，流畅
定义完了，该实现了
```objc
@implementation CalorieRingView
//我们先看这一段的函数
-(instancetype)initWithFrame:(CGRect)frame{
self=[super initWithFrame:frame];
if(self)
{
[self setupLayers];
return self;
}
...
}
```
- 首先，这是个啥？
	这是UIView最标准的程序初始化入口，当你的代码通过[[CalorieRingView alloc] initWithFrame:...]手动创建了这个圆环时，这个代码就会被触发
- 然后呢？我还是不知道这里面写的是啥啊
	别急，这就解释
	1. `self=[super initWithFrame:frame];` 这是继承于初始化
		- 动作： 调用父类（UIView）的初始化方法
		- 意义：UIView需要处理很多的底层工作（设置视图的大小frame，建立坐标系，准备绘图上下文）
		- 赋值给self：oc的安全惯例，如果父类初始化失败返回nil（空），后续操作就停止，防止崩溃
		
	2. if（self）{...}---安全保护
		- 确保父类初始化成功，只有在对象真的存在时，才去执行我们自定义的逻辑
	3. [self setupLayers];---配置核心
		- 最重要！当视图诞生的时候他就去画。
这段代码就像是一个“施工说明书”的第一页：

1. 先领一块地（`initWithFrame`）。
    
2. 确保地领到了（`if (self)`）。
    
3. 立刻动工盖楼（`setupLayers`）。
然后接下来一段代码
```objc
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupLayers];
    }
    return self;
}


}
```
依旧初始化，但是是初始化的storyboard，防止你代码初始化失败他就运行不起来了（当然因为实在.m文件里，story board也是懒得读你，所以该看不见还是看不见）
- 既如此，为什么还要这么写？
	- 因为这叫“双重保险”宝贝儿～
	- 代码走Frame通道，storyboard走coder通道，确保我们的圆能画出来
接下来终于该setup layers了
```objc
-(void) setupLayers{
//背景圆环层
self.backgroundLayer=[CASshapeLayer layer];
self.backgroundLayer.fillColor=[UIColor clearColor].CGColor;
self.backgroundLayer.strokeColor=[UIColor systemGray6Color].CGColor;
self.backgroundLayer.lineWidth=15.0;
self.backgroundLayer.lineCap=kCALineCapRound;
[self.layer addSublayer:self.backgroundLayer];
//接下来是进度层
self.progressLayer=[CAShapeLayer layer];
self.progressLayer.fillColor=[UIColor clearColor].CGColor;
self.progressLayer.lineWidth=15.0;
self.progressLayer.lineCap=kCALineCapRound;
self.progressLayer.strokeEnd=0.0;
[self.layer addSublayer:self.progressLayer];
_progress=0.0;

}
```
这段代码我们分两部分看：
	第一，背景圆（backgroundLayer)
	作用是创建视图的基底
	- fillColor=[UIColor clearColor] 我们只需要画圆环的边框，不用填充内部，所以可以将内部clear，设置为透明的
	- strokeColor 设置边框颜色，采用`systemGray6Color`(浅灰色)，通常作为进度条没被填满时候的颜色
	- `lineWidth=15.0` 规定圆环的厚度（线条宽度）
	- `lineCap=kCALineCapRound` 这是细节优化，让半圆的断点处是圆头的，而不是平的，看起来更高级
	第二，progressLayer，用于真正的创造会动的进度部分
	- strokeEnd=0.0 最关键 的一行，strokeEnd范围从0-1。
		1. 0.0代表路径没有被画出来
		2. 1.0代表完全被展示
		3. 初始设置为0.0，表示进度条一开始是空的
	- _progress=0.0:成员变量，记录当前的进度数值
	第三，图层是怎么叠加的呢？
	- 那就要看我们的 [self.layer addSublayer:...]
		- 第一层（底层）：`backgroundLayer` --这是一个360度的灰色圆环
		- 第二层（顶层）：`progressLayer` -- 这是一个覆盖在上面的彩色圆环（现在还没有设置颜色）
	当你需要更新进度时，只需要修改`self.progressLayer.strokeEnd` 的值就行。
舞台搭建好了，接下来要干什么呢？
```objc
-(void)layoutSubviews{
[super layoutSubviews];
[self updatePaths];
}
```
必要步骤，用`layoutSubview`处理`SUblayers`的尺寸路径
	- 如果不用它处理，在初始化阶段（setupLayers，视图的bounds（尺寸）往往还都是0或者不准确的）
	- 当视图大小发生变化的时候，layoutSubviews会被自动调用自动处理
	- 还可以保证在这里计算的圆心和半径可以让其处于视图正中心
接下来终于该画圆了！

```objc
-(void)updatePaths{
//半圆环，绘制在视图上方
//中心点应该再视图宽度的中心，高度的25%处上方
CGPoint center=CGpointMake(self.bounds.size.width/2,self.bounds.size.height*0.25);
//半径应该是视图宽度和高度中较小的哪一个，减去边距
CGFloat maxRadius=MIN(self.bounds.size.width,self.bounds.size.height*0.8)/2;
CGFloat radius=maxRadius -10;//留出边距
//绘制半圆：从左侧（180）到右侧（0），在上方
UIBezierPath *path=[UIBezierPath bezierPath];
[path addArcWithCenter:center
radius:radius
startAngle:DEGREES_TO_RADIANS(180)
endAngle:DEGREES_TO_RADIANS(0)
clockwise:YES];
self.backgroundLayer.path=path.CGPath;
self.progressLayer.path=path.CGPath;
}
```
这个函数好复杂，没关系我们慢慢看：
	1.  确定圆心的位置： `CGPoint center=CGPointMake(self.bounds.size.width/2,self.bounds.size.heights*0.25);`
		-  `self.bounds.size.width/2` :取视图宽度的一半，保证圆弧在水平方向上绝对的居中
		- `self.bounds.size.height*0.25` :取视图高度的1/4（因为画的是半圆，且取得是圆弧的上半部分，如果是/2的话在圆心在屏幕中间会占用太多的空间
	2.  计算半径的大小 `CGFloat maxRadius=MIN(Self.bounds.size.width,self.bounds.size.height*0.8)/2;`
		-MIN(...,...):取最小值，这是为了做屏幕适配，无论视图是横向还是纵向的长方形，**都可以保证圆弧完整的显示，不会被切掉边缘**
		- `self.height*0.8` 高度压缩一下，保证垂直方向有足够的空间
		- `/2 ` ，直径变成半径
		- `CGFloat radius=maxRadius=10;` ,算出来的半径再-10，保证不会跨越视图边界的安全区
	3. 绘制半圆路径 
		1. `UIBezierPath *path=[UIBezierPath bezierPath];` `UIBezierPath` 相当于画笔，用来描述形状
		2.  `[path addArcWithCenter:cneter radius:radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(0) clockwise:YES];` 绘图逻辑的核心，需要对照坐标系来理解
			1. `startAngle:180` 从左侧开始
			2. `enAngle:0` 到右侧结束
			3. `clockwise:YES` 顺时针旋转，从左侧出发顺时针转到右侧，路径经过“上方”，形成一个拱桥。
	4. 将路径交给图层  `self.backgroundLayer.path=path.CGPath; 
		1.   path.CGPath: `UIBezierPath` 是OC的对象，而`CAShapeLayer`需要的是底层的`CGPathRef`的数据模型 
	   `self.progressLayer.path=path.CGPath;` 
		2.  `backgroundLayer` 拿到路径后，会画出一个完整的灰色半圆
		3.  `progressLayer` 拿到相同的路径，但因为它有`strokeEnd` 属性，他只会根据进度百分比显示路径的一部分（重要！！！）
		

这时候肯定会一脸懵逼：我不是把我圆环的图形给的UIBezierPath吗，怎么最后导入的时候是CGPath这个陌生人？？？
- 这个问题其实很简单，UIBezierPath所属的UIKit属于高级对象，而CoreGraphics相当于底层引擎
-  `UIBezierPath` 是一个OC类，封装着很多的方法，就比如 `addArcWithCenter` 让我们不用写负责的c函数就可以描述形状
- `CGPath` 隶属于（Core Graphics），他是最底层的C语言数据结构（CGPathRef），真正的存储坐标点，弧度等
- 当你调用`addArcWithCenter` 方法的时候，`UIBezierPath` 内部就已经在修改它持有的底层`CGPath` 
- 所以当你执行`self.progressLayer.path=path.CGpath;` 时UIBezierPath 的对象path的属性已经传给了CGPath
接下来这段代码，就是一段属性设置方法（setter方法）
	
```
-(void)setProgress:(CGFloat)progress{
_progress=MAX(0.0,MIN(1.0,progress));
[self setProgress:_progress animated:NO];
}


```
`-(void)setProgress:(CGFloat)progress`
		1. 这是一个Setter方法，按照命名规律，如果你的属性名时`progress` ,那么他的设置方法必须为`setProgress` 
		2. `CGFloat` 浮点数类型，用来接收传入的进度值
	`_progress=MAX(0.0,MIN(1.0,progress));` 防傻子操作，确保进度条不会爆掉，最多满，房子有傻子输入负数导致结果倒挂）
	`[self setProgress:_progress animated:NO];` 
最后，吧setprogress的animated实现
```objc
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {

    _progress = MAX(0.0, MIN(1.0, progress));

    if (animated) {

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];

        animation.fromValue = @(self.progressLayer.strokeEnd);

        animation.toValue = @(_progress);

        animation.duration = 1;

        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        self.progressLayer.strokeEnd = _progress;

        [self.progressLayer addAnimation:animation forKey:@"progressAnimation"];

    } else {

        self.progressLayer.strokeEnd = _progress;

    }

}

  

@end
```
_progress=MAX(0.0,MIN(1.0,progress));
	再次确保传入的值在0.0到1.0之间，保证方法的原子性
如果有动画（if（animated））
	代码就会执行完整的Core Animation流程
		1.先创建一个“基础动画对象”，目标是strokeEnd属性
		`CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];` 
		 2. 再设置一个动画的起点：当前进度 `animation.fromValue=@(self.progressLayer.strokeEnd);`
		 3. 设置动画的终点，目标进度 `animation.toValue=@(_progress);` 
		 4. 动画时长1秒`animation.duiration=1;` 
		 5. 设置时间函数：EaseInEaseOut，代表慢进慢出，看起来更自然，不生硬 `animation.timingFunctin=[CAMediaTimingFuction functionWithName:kCAMediaTimingFucntionEaseInEaseOut];` 
		 6. 关键步骤：先更新模型层的值，防止动画结束跳回原地`self.progressLayer.strokeEnd=_progress;` 
		 7. `[self.progressLayer addAnimation:animation forkey:@"progressAnimation"];` 将动画按在图层上，进度条开始滑动
	![[截屏2025-12-25 11.49.11.png]]
		8. 没有动画时：（else)
		`self.progressLayer.strokeEnd=_progress;`    当然，CALayer存在隐式动画，所以即使你这么设置了，他还是会动的.
		
### 一个隐藏的小知识点

你的代码中有一行： `self.progressLayer.strokeEnd = _progress;` 写在了`addAnimation:` **之前**。

- **为什么要这么写？动画（`CABasicAnimation`）本质上只是一个“表演”，它并不真的改变图层的数据。如果动画结束了，图层会发现自己的`strokeEnd`还是旧的值，就会瞬间弹回去。先赋值、再加动画，相当于“先定好终点，再跑过去”，这样跑完就直接停在终点。
