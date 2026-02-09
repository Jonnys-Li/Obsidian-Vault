## 4.1UILabel 的常见属性
- `@property (nonatomic,copy) NSString *text;`
	- 显示的文字
- `@property(nonatomic, retain) UIFont *font;`
	- 字体
- `@ property(nonatomic, retain) UIColor *textColor;` 
	- 文字颜色
-  `@property(nonatomic) NSTextAlignment textAligment;`
	- 对齐模式（左，右，居中）
- `@property(nonatomic) NSInteger number0fLines;`
	- 文字行数
- `@property(nonatomic) NSLineBreakMode lineBreakMode;`
	- 换行模式
---

### 4.1.1 具体的用法和代码表示
```objc
//

//  ViewController.m

//  UILabel

//

//  Created by zjs on 2025/12/22.

//

  

#import "ViewController.h"

  

@interface ViewController ()

  

@end

  

@implementation ViewController

  

- (void)viewDidLoad {

    [super viewDidLoad];

    //1.1创建UILabel对象

    UILabel *label=[[UILabel alloc]init];

    //1.2设置frame

    label.frame=CGRectMake(100,100,100,75);

    //1.3设置背景颜色

    label.backgroundColor=[UIColor redColor];

    //1.4设置文字

    label.text=@"wo shi le!";

    //1.5居中

    label.textAlignment=NSTextAlignmentCenter;

    //1.6设置字体大小

    label.font=[UIFont systemFontOfSize:20.f];

    label.font=[UIFont boldSystemFontOfSize:25.f];

    label.font=[UIFont italicSystemFontOfSize:20.f];

    //1.7设置文字的颜色

    label.textColor=[UIColor whiteColor];

    //1.8 设置阴影（默认是有值）

    label.shadowColor=[UIColor blueColor];

    label.shadowOffset=CGSizeMake(-2, 1);

    //1.9设置行数（0:自动换行）

    label.numberOfLines=0;

    //1.9显示模式

    label.lineBreakMode=NSLineBreakByWordWrapping;

    /*

     NSLineBreakWordWrapping=0; //Wrap at word Boundaries, default

     NSLineBreakCharWrapping,//Wrap at character boundaries

     NSLineBreakByCliping,//simpky clip

     NSLineBreakByTruncatingHead,//Truncate at head of line:"...wxyz"

     NSlineBreakByTruncatingTail,//Truncate at tail of line:"abcd..."

     NSLineBreakByTruncatingMiddle//truncate middle of line:"ab...yz"

     */

    // Do any additional setup after loading the view.

    [self.view addSubview:label];

}

  

  

@end
```
### 4.1.2 效果展示
![[截屏2025-12-22 10.59.35.png]]
## 4.2 UIImageView
- 功能相当专一：显示图片
---
### 4.2.1 使用方法
```objc
//
//  ViewController.m
//  UIImage
//
//  Created by zjs on 2025/12/22.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.1 创建UIImageView对象
    UIImageView *imageView=[[UIImageView alloc]init];
    //1.2设置frame
    imageView.frame=CGRectMake(100, 100, 200, 200);
    //1.3设置背景
    imageView.backgroundColor=[UIColor greenColor];
    //1.4设置图片(png不需要后缀）
    imageView.image = [UIImage imageNamed:@"image"];
    /**
     UIViewContentModeRedraw, //重新绘制（核心绘图） drawRact
     
     //带有Scale，表明图片有可能被拉伸或压缩
     UIViewContentModeScaleToFill, //完全的压缩或拉伸
     
     //Aspect比例，缩放是带有比例的
     UIViewContentModeScaleAspectFit,  //宽高比不变Fit适应
     UIViewContentModeScaleAspectFill,  //宽高比不变，fill填充
     
//不带Scale，表明图片不可能被拉伸/压缩
     UIViewContentModeCenter,
     UIViewContentModeTop,
     UIViewContentModeBottom,
     UIViewContentModeLeft,
     UIViewContentModeRight,
     UIViewContentModeTopLeft,
     UIViewContentModeTopRight,
     UIViewContentModeBottomLeft,
     UIViewContentModeBottomRight,
     */
    //1.5设置图片的内容模式
    imageView.contentMode= UIViewContentModeScaleAspectFill;
    //图片太大了，所以要裁剪多余的部分
    // 图片会等比例缩放直到铺满整个框，超出部分配合 clipsToBounds 裁剪
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;//直接使用这句话会被直接裁完
    //2.0加到控制器的view中
    [self.view addSubview:imageView];
 
    
}


@end
```
## 4.3 制作毛玻璃效果（部分代码效果）
```objc
    //2设置毛玻璃效果

    //2.1创建UIImageView对象

    UIImageView *imageView=[[UIImageView alloc]init];

    //2.2设置尺寸

    // 这种方法不好 imageView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    //好方法

    imageView.frame=**self**.view.bounds;

    //2.3设置背景颜色

    imageView.backgroundColor=[UIColor whiteColor];

    //2.4设置背景图片(默认scale to fill）

    imageView.image=[UIImage imageNamed:@"image"];

    //2.5设置图片的内容格式

    imageView.contentMode=UIViewContentModeScaleAspectFit;

//    //2.6加毛玻璃(方法太老被废弃）

//    //2.6.1创建一个毛玻璃

//    UIToolbar *toolbar=[[UIToolbar alloc]init];

//    //2.6.2设置toolbar的frame

//    toolbar.frame=imageView.bounds;

//    imageView.userInteractionEnabled = YES;

//    //2.6.3设置玻璃的样式

//    toolbar.barStyle=UIBarStyleDefault;

//    //2.6.4加载到imageview中

//    [imageView addSubview:toolbar];

    // 2.6 加毛玻璃效果

    // 2.6.1 创建模糊效果类型（有 ExtraLight, Light, Dark 等）

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];

  

    // 2.6.2 创建视觉效果视图

    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];

  

    // 2.6.3 设置尺寸

    effectView.frame = imageView.bounds;

  

    // 2.6.4 加到 imageView 中

    [imageView addSubview:effectView];
```
效果图：
![[截屏2025-12-22 15.57.32.png]]
## 4.4UIview中Frame的设置方式
