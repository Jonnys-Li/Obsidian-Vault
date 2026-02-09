# Mode Gallery 功能简介
## 1.运用知识：`UILabel`相关方法，`UIImage`相关方法，`UIBlurEffect`相关方法（`toolbar`创建毛玻璃效果在此版本iOS上已经失效），基本的`IBAction`，`IBOutlet`的使用，页面跳转。
## 2.相关接口：
### 2.1属性接口
| 属性名称 | 类型 | 描述 |
| :--- | :--- | :--- |
| forest | UIButton | 触发森林场景切换的按钮。 |
| city | UIButton | 触发城市场景切换的按钮。 |
| star | UIButton | 触发星空场景切换的按钮。 |
| AmbiguousButton | UIButton | 触发毛玻璃效果开关的按钮。 |
| imageView | UIImageView | 核心展示容器，负责显示当前选中的艺术图片。 |
### 2.2 IBActions接口
| 接口名称 | 功能描述 |
| :--- | :--- |
| LinkTo... | 场景切换接口，动态加载本地图像资源。 |
| setAmbiguousButton | 滤镜控制接口，利用 `UIVisualEffectView` 实现动态毛玻璃叠加。 |
| goto | 导航路由接口，负责实例化 `DetailViewController` 并通过 `Storyboard ID` 实现页面跳转。 |

### 2.3 UI 布局策略
- **标题 (Label)**: 采用 `Auto Layout` (NSLayoutAnchor) 实现适配，确保在不同尺寸 iPhone 上均能完美对齐。
- **画廊 (ImageView)**: 采用精准的 `Frame` 布局，保证视觉焦点的稳定性。