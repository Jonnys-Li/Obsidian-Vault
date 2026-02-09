## UIViewController的生命周期顺序
在最新版本删除了`viewWillUnload` 和 `viewDidUnload` 后
现在的生命周期顺序就变成了五个最重要的核心：
`init`-> `viewDidLoad` -> `viewWilAppear` -> `viewDidAppear`-> `dealloc` 
主要过程：
1. 内存准备和诞生环节
	1. initWithCoder/initWithNibName: 初始化，进行内存的分配
	2. traitOverrides(iOS 17+):设置控制器的颜色和尺寸
2. 视图的构建（只跑一次）
	1. loadView -> 创建self.view
	2. viewDidLoad -> 视图加载完成，进行基础的配置
	3. updateViewConstraints  -> 开始创建Auto Layout约束
3. 动态显示和布局（可以多次）
	1. viewWillAppear -> 动画即将开始
	2. viewISAppearing -> *重点！* 此时View已经在窗口，尺寸已经正确，最适合 **初始化UI数据** 
	3. viewWillLayoutSubviews -> 即将计算子视图的位置
	4. viewDidLayoutSubviews -> 布局完成，此时获取`subview.frame` 最准确
	5. `viewDidAppear` 界面完全呈现，可以安全的执行用户引导动画或者启动计时器
4. 环境适配（随时）
	1.  `viewWillTransitionToSize:WithTransitionCoordingtor` -> 屏幕旋转或分屏
	2. `traitCollectionDidChange` 切换模式
	3. `updateContentUnavailableConfigurationUsingState` 当数据从无到有或从有到无切换空状态界面
5. 清理退出
	1. `viewWillDisappear` 即将离开
	2. `viewDidDisappear` 彻底离开
	3. `dealloc` 彻底销毁
## 如何去进行解读理解？

## 每一个生命周期对应该写什么模块？
| **任务类型**           | **推荐位置**                                              | **核心原因**             |
| ------------------ | ----------------------------------------------------- | -------------------- |
| **创建 View/约束**     | `viewDidLoad`                                         | 只需执行一次               |
| **修改 Frame/Layer** | `viewDidLayoutSubviews`                               | 此时 Auto Layout 计算已完成 |
| **网络数据请求**         | `viewDidLoad` (静默加载) 或 `viewDidAppear` (带 Loading 动画) | 避免阻塞主线程显示            |
| **导航栏显示/隐藏**       | `viewWillAppear`                                      | 保证转场动画平滑             |
| **动画启动**           | `viewDidAppear`                                       | 视图已完全显示，动画才流畅        |

## 进阶：当存在多个页面时，生命周期是如何调度的？
### 页面跳转（A-> B)
1.  B加载：`B.viewDidLoad()` （仅第一次创建时调用）
2.  A即将消失`A.viewWillDisappear()` 
3. B即将显示 ` B.viewWillAppear()` 
4. A彻底消失 `A.viewDidDisappear()` 
5. B彻底显示 `B.viewDidAppear()` 
### 页面返回（B->A)
1. B即将消失： `B.viewWIllDIsappear()` 
2. A即将重新显示`A.viewWillAppear()`
3. B彻底消失 `B.viewDidDisappear()` 
4. A彻底显示 `A.viewDidAppear()` 
5.  B销毁 `B.deinit` (B从内存中释放，而A一直在内存中)
### 模块化（Encapsulation）的习惯

在 Objective-C 开发规范中，通常会将方法归类：

- **Lifecycle:** 存放 `viewDidLoad`, `viewWillAppear` 等。
    
- **Setup Methods:** 存放 UI 初始化代码。
    
- **Action Methods:** 存放按钮点击事件。
    
- **Delegate Methods:** 存放代理回调。
## MVC架构
- 简单来说就是Model-View- Controller的架构
- Model用来存放数据，View主要负责视图，Controller用来写约束，代理，逻辑实现
### ### 1. MVC 的通信规则（重点）

为了保持代码整洁，MVC 规定了严密的通信方式：

- **Controller 可以直接访问 Model 和 View**（它是它们的老板）。
    
- **Model 和 View 绝不能直接通信**。
    
- **View 告诉 Controller**：通过 **Target-Action**（按钮点击）或 **Delegate**（代理，就像你代码里写的那样）。
    
- **Model 告诉 Controller**：通过 **Notification**（通知）或 **KVO**（键值监听）。
## Push和Present
| **特性**   | **Push (推入)**                     | **Present (模态弹出)**                           |
| -------- | --------------------------------- | -------------------------------------------- |
| **层级关系** | 属于 **Navigation Stack**（导航栈）。     | 属于 **Modal Presentation**（模态呈现）。             |
| **依赖环境** | 必须嵌套在 `UINavigationController` 中。 | 任何 `UIViewController` 都可以调用。                 |
| **用户感知** | 水平滑入（从右向左），带有导航栏和返回按钮。            | 垂直弹入（从下向上），通常不带导航栏（需手动加）。                    |
| **逻辑意义** | 用于 **层级导航**（如：设置 -> 通用 -> 关于）。    | 用于 **临时任务**（如：登录、写邮件、弹窗确认）。                  |
| **代码实现** | `pushViewController:animated:`    | `presentViewController:animated:completion:` |
| **销毁方式** | `popViewControllerAnimated:`      | `dismissViewControllerAnimated:completion:`  |
![[截屏2025-12-29 18.59.34.png]]
像这种就是present方式
今日还没有完全学习的概念：KVO

## Autolayout原生库和第三方库用法的区别
原生auto layout ：
	1. 需要直接用对象名，从对象中取值
	2. 原定其上下左右需要用topAnchor等等各种Anchor来约束，写法麻烦
	3. 每一条constraints都需要事先声明`translatesAutoresizing MaskInto Constraints=NO；` 把父子视图auto resizing关闭，防止因为兼容问题报错。
使用第三方库masonry：
1. 写法更自然，如想要调整ringView和contentView的约束，直接if（self.RingView && self.ContentView)
2. 用法简化

```objc
 if (self.ringView && self.contentView) {
        // ========== Masonry 方式 ==========
        [self.ringView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(20);
            make.trailing.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.contentView).offset(30);
            // 使用宽高比保持圆环比例，高度约为宽度的 0.64 (180/280)
            make.height.equalTo(self.ringView.mas_width).multipliedBy(0.64);
        }];
```
只需要这几行就可以完成创建所有约束
把所有约束用临时对象MAXConstraintMaker的对象make内部的临时数组封装，所有make就可以访问到object的所有值
3. 更精致的语法：用leading，equalto等方法让整体可读性变简单
## Push 和Present的应用
#### 使用 Push 的场景

- 列表 → 详情页

- 主页面 → 子页面（需要返回）

- 设置 → 子设置项

- 任何需要导航栈管理的页面
![[截屏2025-12-30 11.01.37.png]]
使用Push后跳转到一个新的页面，顶部也会有导航栏可以返回上一个页面（可隐藏）
同时，因为push方法必须要有导航栏，所以如果你的ViewController没有在Navigation COntroller中的话，需要在SceneDelegate.m中手动加入下面的代码，确保Push方法可以调用
```objc
-(void) scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions{
//在原本代码下写
//获取Window的rootView Controller（ViewController）
UIViewController *rootVC=self.window.rootViewController;
//如果rootViewController不是NacigationCOntroller，就包装
if(rootVC && ![rootVC isKindOfClass:[UINavigationController class]])
{
UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:rootVC];
self.window.rootViewController=navController;
}
}
```

#### 使用 Present 的场景

- 登录页面

- 临时任务（拍照、选择图片）

- Alert、ActionSheet

- 独立功能模块（不需要返回主流程）

- 当前页面不在 NavigationController 中时![[截屏2025-12-30 11.02.32.png]]![[截屏2025-12-30 11.02.47.png]]
使用present会叠加在当前页面上，在生命周期中不销毁上一个页面，不入栈


