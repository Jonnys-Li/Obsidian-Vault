
## 一：核心组件：UIView 和CALayer的区别

* UIView（UIKit框架）：只能在iOS端运行，是对CALayer的封装，主要负责内容渲染和事件响应
* CALayer（QuartzCore框架），具有跨平台的特点（苹果生态跨平台）。可以直接与GPU通信，负责位图合成，速度快
![[截屏2026-01-20 18.12.46.png]]

## 二：Layer的几何属性：

* position：决定的Layer在父层坐标系中的坐标点（参考原点在父层的左上角（0，0）
* anchorPoint（锚点）：决定的是Layer上那个店重合在position所指的位置；取值范围从（0，1）；默认值是（0.5，0.5），几何的中心

## 三：Core Animation

1. 动画特性
    1. 直接作用于CALayer，不是UIView
    2. 核心动画改编的是显示层，而不是模型层，动画结束后Layer的真实属性（frame）并不会改变
    3. 使用场景：有复杂的转场动画的场景，不需要用户交互的场景，需要沿路径运动的场景
2. 关键属性：

```
// 1. 创建动画对象 (以关键帧动画为例)
CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];

// 2. 设置动画属性
anim.keyPath = @"position";  // 动画属性路径
anim.values = @[...];        // 关键帧路径点
anim.duration = 2.0;         // 持续时间
anim.repeatCount = MAXFLOAT; // 无限循环
anim.autoreverses = YES;     // 自动反转

// 3. 添加到图层
[self.myView.layer addAnimation:anim forKey:nil];
//4.动画组
CAAnimationGroup *group = [CAAnimationGroup animation]; 
group.animations = @[animRotate, animScale]; // 将旋转与缩放动画组合
```

## 四：CADisplayLink：屏幕刷新检测

* 本质：一个能够给让我们以与屏幕刷新率相同的频率将内容滑倒屏幕上的定时器
* 原理：
    * 初始化`CADisplayLink` 并将其加入`NSRunLoop` 
    * 在回调方法中统计一秒内触发的次数
    * 计算公式：FPS=刷新次数/总耗时
* 核心代码实现：

```
//1.定义变量
@property (nonatomic , strong) CADisplayLink *link;
@property (nonatomic ,strong ) NSTimeInterval lastTime;
@property (nonatomic ,assign) NSInteger count;
//2.初始化并开启
    -(void) startFPSMonitoring{
//保持对self的弱引用，防止循环引用
self.link=[CADisplayLink displayLinkWithTarget:self selector:@selecltor(fpsTick:)];
[self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
//回调计算
    -(void) fpsTick:(CADisplyLink *) link
    {
    if(_lastTime==0)
    {
    _lastTime= link.timestamp;
    return;
    }
_count++;
NSTimeInterval delta=link.timestamp - _lastTime;//计算时间间隔
if(delta <1.0) return;
float fps=_count/delta;
NSLog(@"当前FPS： %.1f",fps);

//重置统计变量
_lastTime=link.timestamp;
_count= 0;

}

```




## 明日学习计划

* 深入学习UIView的渲染
* UITabView的性能优化
* 自定义Layout

