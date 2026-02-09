# 卡路里追踪应用 API 文档

## 项目概述

这是一个 iOS 卡路里和宏量营养素追踪应用，使用 Objective-C 开发。应用支持记录每日食物摄入、追踪卡路里消耗和宏量营养素（碳水化合物、蛋白质、脂肪）的进度。

---

## 目录

- [FoodItem - 食物项模型](#fooditem---食物项模型)

- [NutrientModel - 营养素模型](#nutrientmodel---营养素模型)

- [DailyLogModel - 每日日志模型](#dailylogmodel---每日日志模型)

- [CalorieRingView - 卡路里圆环视图](#calorieringview---卡路里圆环视图)

- [ViewController - 主视图控制器](#viewcontroller---主视图控制器)

---

## FoodItem - 食物项模型

### 类描述

表示单个食物项，包含食物的营养信息和所属餐点类型。

### 头文件

```objc
#import "FoodItem.h"
```

### 枚举类型

#### MealType

餐点类型枚举

```objc
typedef NS_ENUM(NSInteger, MealType) {
    MealTypeBreakfast = 1,  // 早餐
    MealTypeLunch = 2,       // 午餐
    MealTypeDinner = 3,      // 晚餐
    MealTypeSnack = 4        // 零食
};
```

### 属性

|属性名|类型|说明|
|---|---|---|
|`name`|`NSString *`|食物名称|
|`calories`|`NSInteger`|卡路里（千卡）|
|`carbs`|`CGFloat`|碳水化合物（克）|
|`protein`|`CGFloat`|蛋白质（克）|
|`fat`|`CGFloat`|脂肪（克）|
|`mealType`|`MealType`|所属餐点类型|
|`dateAdded`|`NSDate *`|添加日期|

### 类方法

#### + foodWithName:calories:carbs:protein:fat:mealType:

创建并返回一个食物项实例。

**参数：**

- `name` (NSString *): 食物名称
- `calories` (NSInteger): 卡路里值
- `carbs` (CGFloat): 碳水化合物克数
- `protein` (CGFloat): 蛋白质克数
- `fat` (CGFloat): 脂肪克数
- `mealType` (MealType): 餐点类型

**返回值：**

- `FoodItem *`: 新创建的食物项实例

**示例：**

```objc
FoodItem *apple = [FoodItem foodWithName:@"苹果" 
                                 calories:80 
                                    carbs:20 
                                  protein:0.5 
                                      fat:0.3 
                                 mealType:MealTypeBreakfast];
```

---

## NutrientModel - 营养素模型

### 类描述

表示单个营养素的当前值和目标值，用于计算进度。

### 头文件

```objc
#import "NutrientModel.h"
```

### 属性

|属性名|类型|说明|
|---|---|---|
|`currentAmount`|`CGFloat`|当前摄入量（克）|
|`targetAmount`|`CGFloat`|目标摄入量（克）|

### 实例方法

#### - progress

计算并返回当前进度（0.0 到 1.0）。

**返回值：**

- `CGFloat`: 进度值，范围 0.0 - 1.0。如果目标值为 0 或负数，返回 0.0。

**示例：**

```objc
NutrientModel *carbs = [[NutrientModel alloc] init];
carbs.currentAmount = 132.0;
carbs.targetAmount = 200.0;
CGFloat progress = carbs.progress; // 返回 0.66
```

---

## DailyLogModel - 每日日志模型

### 类描述

表示某一天的饮食日志，包含所有添加的食物和计算后的营养数据。

### 头文件

```objc
#import "DailyLogModel.h"
```

### 属性

|属性名|类型|说明|
|---|---|---|
|`date`|`NSDate *`|日期|
|`caloriesLeft`|`NSInteger`|剩余卡路里|
|`caloriesTarget`|`NSInteger`|卡路里目标（默认 2000）|
|`carbs`|`NutrientModel *`|碳水化合物数据|
|`protein`|`NutrientModel *`|蛋白质数据|
|`fat`|`NutrientModel *`|脂肪数据|
|`foodItems`|`NSMutableArray<FoodItem *> *`|已添加的食物列表|

### 类方法

#### + mockDataForToday

创建包含测试数据的今日日志模型。

**返回值：**

- `DailyLogModel *`: 包含预设测试食物的日志模型

**示例：**

```objc
DailyLogModel *today = [DailyLogModel mockDataForToday];
```

#### + modelForDate:

创建指定日期的空日志模型。

**参数：**

- `date` (NSDate *): 日期

**返回值：**

- `DailyLogModel *`: 新创建的空日志模型

**示例：**

```objc
NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
DailyLogModel *log = [DailyLogModel modelForDate:yesterday];
```

### 实例方法

#### - addFoodItem:

添加食物项并自动重新计算所有数据。

**参数：**

- `foodItem` (FoodItem *): 要添加的食物项

**说明：** 添加食物后会自动调用 `recalculate` 方法更新所有营养数据。

**示例：**

```objc
FoodItem *food = [FoodItem foodWithName:@"香蕉" calories:105 carbs:27 protein:1.3 fat:0.4 mealType:MealTypeSnack];
[dailyLog addFoodItem:food];
```

#### - recalculate

重新计算所有营养数据。

**说明：**

- 累加所有食物的卡路里和宏量营养素
- 更新 `caloriesLeft`（目标卡路里 - 已消耗卡路里）
- 更新各营养素的 `currentAmount`

**调用时机：**

- 添加新食物时自动调用
- 可手动调用以刷新数据

**示例：**

```objc
[dailyLog recalculate];
```

---

## CalorieRingView - 卡路里圆环视图

### 类描述

自定义视图，显示半圆形卡路里进度环。

### 头文件

```objc
#import "CalorieRingView.h"
```

### 属性

|属性名|类型|说明|
|---|---|---|
|`progress`|`CGFloat`|进度值（0.0 到 1.0）|

### 实例方法

#### - setProgress:animated:

设置进度值，可选择是否动画。

**参数：**

- `progress` (CGFloat): 进度值，范围 0.0 - 1.0，超出范围会自动限制
- `animated` (BOOL): 是否使用动画

**说明：**

- 进度值会自动限制在 0.0 到 1.0 之间
- 如果 `animated` 为 YES，进度变化会有 0.5 秒的动画效果

**示例：**

```objc
[ringView setProgress:0.7 animated:YES];
```

### 视觉特性

- **圆环样式：**
    
    - 背景圆环：浅灰色（systemGray6Color）
    - 进度圆环：绿色（systemGreenColor）
    - 线宽：15.0 点
    - 圆角端点：kCALineCapRound
- **绘制方式：**
    
    - 半圆形，从左侧（180度）到右侧（0度）
    - 中心位置在视图高度的 25% 处
    - 半径根据视图大小自适应

---

## ViewController - 主视图控制器

### 类描述

应用的主视图控制器，管理整个界面的显示和交互。

### 头文件

```objc
#import "ViewController.h"
```

### IBOutlet 属性

|属性名|类型|说明|
|---|---|---|
|`previousDayButton`|`UIButton *`|前一天按钮|
|`nextDayButton`|`UIButton *`|后一天按钮|
|`dateLabel`|`UILabel *`|日期标签|
|`ringView`|`CalorieRingView *`|卡路里圆环视图|
|`caloriesLeftLabel`|`UILabel *`|剩余卡路里数字标签|
|`kcalLeftLabel`|`UILabel *`|"kcal left" 文字标签|
|`fabButton`|`UIButton *`|浮动操作按钮（FAB）|

### 私有属性

|属性名|类型|说明|
|---|---|---|
|`currentDate`|`NSDate *`|当前显示的日期|
|`dailyLog`|`DailyLogModel *`|当前日期的日志数据|
|`mealTypeButtons`|`NSArray<UIButton *> *`|餐点类型按钮数组|
|`selectedMealTypeIndex`|`NSInteger`|当前选中的餐点类型索引（0-4）|
|`recentlyLoggedLabel`|`UILabel *`|"Recently Logged" 标题标签|
|`addToMealButton`|`UIButton *`|"Add to Breakfast" 按钮|
|`bottomTabBar`|`UIView *`|底部导航栏视图|
|`macrosContainerView`|`UIView *`|宏量营养素容器视图|
|`carbsLabel`|`UILabel *`|碳水化合物标签|
|`carbsProgressView`|`UIProgressView *`|碳水化合物进度条|
|`proteinLabel`|`UILabel *`|蛋白质标签|
|`proteinProgressView`|`UIProgressView *`|蛋白质进度条|
|`fatLabel`|`UILabel *`|脂肪标签|
|`fatProgressView`|`UIProgressView *`|脂肪进度条|

### IBAction 方法

#### - previousDayTapped:

点击前一天按钮时调用。

**参数：**

- `sender` (id): 发送者（按钮）

**功能：**

- 将当前日期向前移动一天
- 调用 `loadDataForDate:` 加载新日期的数据

#### - nextDayTapped:

点击后一天按钮时调用。

**参数：**

- `sender` (id): 发送者（按钮）

**功能：**

- 将当前日期向后移动一天
- 不允许选择未来日期
- 调用 `loadDataForDate:` 加载新日期的数据

#### - fabButtonTapped:

点击浮动操作按钮时调用。

**参数：**

- `sender` (id): 发送者（按钮）

**功能：**

- 显示快速添加食物对话框
- 如果当前选择的是 "All"，默认添加到 Breakfast
- 提供快速添加（只需名称和卡路里）和详细添加选项

### 公共方法

#### - loadDataForDate:

加载指定日期的数据。

**参数：**

- `date` (NSDate *): 要加载的日期

**功能：**

- 更新 `currentDate`
- 更新日期标签显示
- 如果是今天，加载包含测试数据的模型；否则创建空模型
- 调用 `updateUI` 更新界面

**示例：**

```objc
NSDate *date = [NSDate date];
[self loadDataForDate:date];
```

### 私有方法

#### - viewDidLoad

视图加载完成时调用。

**功能：**

- 初始化当前日期为今天
- 设置默认选中的餐点类型为 Breakfast
- 设置圆环内部标签
- 加载今天的数据
- 设置 FAB 按钮样式
- 创建所有 UI 元素

#### - viewDidLayoutSubviews

视图布局完成时调用。

**功能：**

- 调整圆环视图位置和大小
- 布局圆环内部标签
- 布局宏量营养素 UI
- 布局餐点类型按钮
- 布局最近记录区域
- 布局底部导航栏

#### - setupRingViewLabels

设置圆环视图内部的标签。

**功能：**

- 创建顶部同步图标
- 将卡路里标签添加到圆环视图
- 设置圆环视图背景为透明

#### - layoutRingView

布局圆环视图的位置和大小。

**功能：**

- 计算圆环视图的 frame
- 居中显示，从顶部 120 点开始
- 宽度 280，高度 180

#### - layoutRingViewLabels

布局圆环视图内部的标签位置。

**功能：**

- 设置同步图标位置（顶部 15 点）
- 设置卡路里数字标签位置和字体（48 号粗体）
- 设置 "kcal left" 标签位置和字体（16 号）

#### - setupMacrosUI

创建宏量营养素 UI 元素。

**功能：**

- 创建容器视图（白色卡片，带阴影）
- 创建碳水化合物、蛋白质、脂肪的图标、标签、进度条和数值标签
- 设置各元素的颜色和样式

#### - layoutMacrosUI

布局宏量营养素卡片位置。

**功能：**

- 计算卡片位置（圆环下方 40 点）
- 设置卡片大小和位置

#### - getValueLabelForTag:

根据 tag 获取数值标签。

**参数：**

- `tag` (NSInteger): 标签的 tag 值（100: 碳水, 101: 蛋白质, 102: 脂肪）

**返回值：**

- `UILabel *`: 对应的标签，如果未找到返回 nil

#### - setupMealTypeButtons

创建餐点类型按钮。

**功能：**

- 创建 5 个餐点类型按钮（All, Breakfast, Lunch, Dinner, Snack）
- 设置按钮样式和点击事件
- 默认选中 Breakfast

#### - layoutMealTypeButtons

布局餐点类型按钮位置。

**功能：**

- 计算按钮位置（宏量营养素卡片下方 30 点）
- 水平排列，按钮之间间距 8 点

#### - updateMealTypeButtonStates

更新餐点类型按钮的选中状态。

**功能：**

- 选中的按钮：绿色背景，白色文字
- 未选中的按钮：白色背景，灰色文字，带边框

#### - mealTypeButtonTapped:

餐点类型按钮点击事件。

**参数：**

- `sender` (UIButton *): 被点击的按钮

**功能：**

- 更新选中的餐点类型索引
- 更新按钮状态
- 更新 "Add to" 按钮文本

#### - setupRecentlyLoggedSection

创建最近记录区域 UI。

**功能：**

- 创建 "Recently Logged" 标题标签
- 创建 "Add to Breakfast" 按钮

#### - layoutRecentlyLoggedSection

布局最近记录区域位置。

**功能：**

- 计算标题和按钮位置（餐点类型按钮下方 30 点）
- 设置按钮大小和位置

#### - addToMealButtonTapped:

"Add to Breakfast" 按钮点击事件。

**参数：**

- `sender` (UIButton *): 被点击的按钮

**功能：**

- 如果选择的是 "All"，提示选择具体餐点
- 显示详细添加食物对话框（5 个输入框：名称、卡路里、碳水、蛋白质、脂肪）
- 添加食物后更新 UI

#### - setupBottomTabBar

创建底部导航栏。

**功能：**

- 创建导航栏容器视图（白色，带阴影）
- 创建 5 个导航标签（Daily, Fasting, Scanner, Explore, Mine）
- 设置图标和文字
- Scanner 标签默认选中（黑色，带下划线）

#### - layoutBottomTabBar

布局底部导航栏位置。

**功能：**

- 计算导航栏位置（屏幕底部，考虑安全区域）
- 创建或更新导航按钮位置
- 设置选中指示器位置

#### - tabButtonTapped:

底部导航栏按钮点击事件。

**参数：**

- `sender` (UIButton *): 被点击的按钮

**功能：**

- 显示导航提示（当前为占位实现）

#### - updateDateLabel

更新日期标签显示。

**功能：**

- 如果是今天，显示 "Today"
- 否则显示日期格式（如 "Dec 23"）
- 禁用未来日期的后一天按钮

#### - updateUI

更新所有 UI 元素显示。

**功能：**

- 更新剩余卡路里数字
- 计算并更新圆环进度
- 更新宏量营养素的数值和进度条
- 设置各进度条的颜色（蓝色、红色、黄色）

**调用时机：**

- 加载新日期数据后
- 添加食物后

---

## 数据流程

### 添加食物流程

```
用户点击添加按钮
    ↓
显示输入对话框
    ↓
用户输入食物信息
    ↓
创建 FoodItem 对象
    ↓
调用 dailyLog.addFoodItem:
    ↓
自动调用 recalculate
    ↓
更新 dailyLog 的所有数据
    ↓
调用 updateUI
    ↓
更新所有 UI 元素（卡路里、圆环、宏量营养素）
```

### 日期切换流程

```
用户点击日期导航按钮
    ↓
计算新日期
    ↓
调用 loadDataForDate:
    ↓
创建或加载 DailyLogModel
    ↓
调用 updateDateLabel
    ↓
调用 updateUI
    ↓
更新界面显示
```

---

## 常量值

### 默认目标值

- **卡路里目标：** 2000 kcal
- **碳水化合物目标：** 200 g
- **蛋白质目标：** 150 g
- **脂肪目标：** 60 g

### UI 间距

- **圆环顶部间距：** 120 点
- **圆环与宏量营养素卡片：** 40 点
- **宏量营养素卡片与餐点按钮：** 30 点
- **餐点按钮与最近记录：** 30 点
- **标题与按钮：** 16 点

---

## 注意事项

1. **日期限制：** 不允许选择未来日期
2. **数据持久化：** 当前版本数据仅保存在内存中，应用重启后会重置
3. **餐点类型：** 选择 "All" 时无法添加食物，需要选择具体餐点
4. **快速添加：** FAB 按钮的快速添加功能会根据卡路里自动估算宏量营养素
5. **圆环进度：** 进度值自动限制在 0.0 - 1.0 之间

---

## 版本信息

- **开发语言：** Objective-C
- **最低 iOS 版本：** iOS 13.0+
- **开发工具：** Xcode 14.0+

---

## 更新日志

### v1.0.0

- 初始版本
- 实现基本的卡路里和宏量营养素追踪
- 支持添加食物和动态更新数据
- 实现日期导航功能
- 实现餐点类型筛选