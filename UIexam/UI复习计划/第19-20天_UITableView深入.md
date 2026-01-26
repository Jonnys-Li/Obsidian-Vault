# 第19-20天：UITableView 深入

## 核心知识点总结

### 1. UITableView 基础

#### 数据源方法（UITableViewDataSource）
- `numberOfSectionsInTableView:` - 返回分组数量
- `tableView:numberOfRowsInSection:` - 返回每个分组的行数
- `tableView:cellForRowAtIndexPath:` - 返回Cell实例

#### 代理方法（UITableViewDelegate）
- `tableView:heightForRowAtIndexPath:` - 返回Cell高度
- `tableView:didSelectRowAtIndexPath:` - Cell点击事件
- `tableView:willDisplayCell:forRowAtIndexPath:` - Cell即将显示

### 2. Cell 重用机制

#### 核心方法
```objc
// 注册Cell类
[tableView registerClass:[CustomCell class] forCellReuseIdentifier:@"CellID"];

// 注册Nib
[tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] 
    forCellReuseIdentifier:@"CellID"];

// 从重用池获取Cell
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
```

#### 重用池原理
- UITableView维护一个Cell重用池
- 当Cell滚出屏幕时，会被放入重用池
- 需要新Cell时，优先从重用池获取
- 如果重用池为空，才创建新Cell

### 3. Cell 高度计算

#### 固定高度
```objc
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}
```

#### 动态高度
- 使用AutoLayout自动计算
- 设置`estimatedRowHeight`和`rowHeight = UITableViewAutomaticDimension`
- 或手动计算高度并缓存

### 4. 高度缓存策略

```objc
// 使用字典缓存高度
@property (nonatomic, strong) NSMutableDictionary *heightCache;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", indexPath.section, indexPath.row];
    NSNumber *cachedHeight = self.heightCache[key];
    if (cachedHeight) {
        return [cachedHeight floatValue];
    }
    
    // 计算高度
    CGFloat height = [self calculateHeightForIndexPath:indexPath];
    self.heightCache[key] = @(height);
    return height;
}
```

### 5. 性能优化

- 减少视图层级
- 避免在`cellForRowAtIndexPath:`中做复杂计算
- 使用高度缓存避免重复计算
- 图片异步加载和缓存
- 使用`estimatedHeight`优化初始渲染

---

## 面试题

### 基础题

#### 1. UITableView的数据源方法和代理方法有什么区别？

**答案：**
- **数据源方法（UITableViewDataSource）**：负责提供数据，告诉TableView有多少行、多少分组、每个Cell的内容
- **代理方法（UITableViewDelegate）**：负责处理交互和外观，如Cell高度、点击事件、显示时机等

#### 2. 什么是Cell重用机制？为什么要使用重用机制？

**答案：**
Cell重用机制是UITableView的核心优化机制：
- 当Cell滚出屏幕时，不会立即销毁，而是放入重用池
- 需要新Cell时，优先从重用池获取，避免频繁创建和销毁
- 好处：减少内存占用、提高滚动性能、降低CPU消耗

#### 3. `dequeueReusableCellWithIdentifier:` 和 `dequeueReusableCellWithIdentifier:forIndexPath:` 有什么区别？

**答案：**
- `dequeueReusableCellWithIdentifier:`：如果重用池为空，返回nil，需要手动判断并创建Cell
- `dequeueReusableCellWithIdentifier:forIndexPath:`：如果重用池为空，会自动创建Cell（需要先注册），不会返回nil

#### 4. 如何实现动态高度的Cell？

**答案：**
方法一：使用AutoLayout自动计算
```objc
tableView.estimatedRowHeight = 100;
tableView.rowHeight = UITableViewAutomaticDimension;
```

方法二：手动计算并缓存
```objc
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使用缓存或计算高度
}
```

### 进阶题

#### 5. Cell重用机制的原理是什么？底层是如何实现的？

**答案：**
- UITableView内部维护一个`NSMutableSet`类型的重用池
- 当Cell滚出可见区域时，调用`prepareForReuse`方法，然后放入重用池
- 需要新Cell时，根据identifier从重用池中查找匹配的Cell
- 如果找到，调用`prepareForReuse`重置状态后返回
- 如果没找到且已注册，创建新Cell；未注册则返回nil

#### 6. 为什么在`cellForRowAtIndexPath:`中配置Cell时，需要重置Cell的状态？

**答案：**
- 因为Cell是重用的，可能之前显示过其他数据
- 如果不重置，可能显示错误的数据（如选中状态、图片等）
- 应该在`prepareForReuse`中重置状态，或在`cellForRowAtIndexPath:`中完整配置

#### 7. 高度缓存的最佳实践是什么？

**答案：**
- 使用字典缓存计算过的高度，key可以是`indexPath`的字符串表示
- 在数据更新时清空缓存
- 对于固定高度的Cell，直接返回固定值，不需要缓存
- 使用`estimatedHeight`提供估算值，优化初始渲染性能

#### 8. 如何优化UITableView的滚动性能？

**答案：**
1. **Cell重用**：正确使用重用机制
2. **高度缓存**：缓存Cell高度，避免重复计算
3. **减少视图层级**：简化Cell的视图结构
4. **异步加载**：图片、网络请求等异步处理
5. **避免主线程阻塞**：不在主线程做复杂计算
6. **使用`estimatedHeight`**：提供估算高度，优化初始布局
7. **减少透明视图**：避免使用`alpha < 1.0`的视图

### 原理题

#### 9. `estimatedRowHeight`的作用是什么？它是如何优化性能的？

**答案：**
- `estimatedRowHeight`提供一个估算的Cell高度
- UITableView使用这个值来估算contentSize，避免在初始渲染时计算所有Cell的高度
- 只有当Cell即将显示时，才会调用`heightForRowAtIndexPath:`计算真实高度
- 这样可以大幅提升初始渲染速度，特别是对于有大量Cell的列表

#### 10. Cell的`prepareForReuse`方法什么时候调用？应该在这里做什么？

**答案：**
- 调用时机：Cell从重用池取出，即将被重新使用时
- 应该做的事情：
  - 重置Cell的状态（如选中状态、高亮状态）
  - 清空可能变化的数据（如图片、文本等）
  - 取消之前的网络请求或异步任务
- 不应该做的事情：
  - 不要在这里设置固定不变的数据（应该在`cellForRowAtIndexPath:`中设置）

---

## 实操题

### 实操题1：实现基础TableView列表

#### 需求描述
实现一个显示联系人列表的TableView，每个Cell显示姓名和头像。

#### 实现步骤

1. **创建数据模型**
```objc
// ContactModel.h
@interface ContactModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatarURL;
@end
```

2. **创建自定义Cell**
```objc
// ContactCell.h
@interface ContactCell : UITableViewCell
- (void)configureWithContact:(ContactModel *)contact;
@end
```

3. **实现ViewController**
```objc
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ContactModel *> *contacts;
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self loadData];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[ContactCell class] forCellReuseIdentifier:@"ContactCell"];
    [self.view addSubview:self.tableView];
}
```

#### 关键代码

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    ContactModel *contact = self.contacts[indexPath.row];
    [cell configureWithContact:contact];
    return cell;
}
```

#### 性能优化点
- 使用Cell重用机制
- 图片异步加载
- 避免在Cell中创建重复视图

---

### 实操题2：实现Cell重用机制演示

#### 需求描述
创建一个演示Cell重用机制的示例，通过打印日志观察Cell的创建和重用过程。

#### 实现步骤

1. **在Cell中添加标识**
```objc
// CustomCell.m
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        static NSInteger cellCount = 0;
        self.cellNumber = ++cellCount;
        NSLog(@"创建Cell #%ld, identifier: %@", self.cellNumber, reuseIdentifier);
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    NSLog(@"Cell #%ld 准备重用", self.cellNumber);
}
```

2. **观察重用过程**
- 滚动TableView，观察控制台日志
- 会发现：初始创建少量Cell，之后都是重用

#### 关键代码

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    NSLog(@"使用Cell #%ld 显示第%ld行", cell.cellNumber, indexPath.row);
    return cell;
}
```

---

### 实操题3：实现高度缓存优化

#### 需求描述
实现一个包含动态高度Cell的列表，使用高度缓存优化性能。

#### 实现步骤

1. **创建高度缓存工具类**
```objc
// HeightCache.h
@interface HeightCache : NSObject
- (void)cacheHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCache;
@end
```

2. **在ViewController中使用**
```objc
@property (nonatomic, strong) HeightCache *heightCache;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 先从缓存获取
    CGFloat cachedHeight = [self.heightCache heightForIndexPath:indexPath];
    if (cachedHeight > 0) {
        return cachedHeight;
    }
    
    // 计算高度
    CGFloat height = [self calculateHeightForIndexPath:indexPath];
    [self.heightCache cacheHeight:height forIndexPath:indexPath];
    return height;
}
```

#### 关键代码

```objc
- (CGFloat)calculateHeightForIndexPath:(NSIndexPath *)indexPath {
    // 使用系统方法计算高度
    static CustomCell *templateCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        templateCell = [self.tableView dequeueReusableCellWithIdentifier:@"CellID"];
    });
    
    // 配置模板Cell
    [templateCell configureWithData:self.dataArray[indexPath.row]];
    
    // 计算高度
    CGSize size = [templateCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1; // +1 for separator
}
```

#### 性能优化点
- 使用模板Cell计算高度，避免创建大量Cell
- 缓存计算结果，避免重复计算
- 数据更新时清空缓存

---

### 实操题4：实现动态高度Cell列表

#### 需求描述
实现一个朋友圈样式的列表，每条动态内容长度不同，需要动态计算高度。

#### 实现步骤

1. **设计Cell布局**
- 使用AutoLayout布局
- 设置内容Label的`numberOfLines = 0`
- 设置约束优先级

2. **配置TableView**
```objc
self.tableView.estimatedRowHeight = 200;
self.tableView.rowHeight = UITableViewAutomaticDimension;
```

3. **实现Cell配置**
```objc
- (void)configureWithModel:(FeedModel *)model {
    self.contentLabel.text = model.content;
    // 其他配置...
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}
```

#### 关键代码

```objc
// FeedCell.m
- (void)setupConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-10);
    }];
}
```

#### 性能优化点
- 使用`estimatedRowHeight`优化初始渲染
- 对于复杂Cell，考虑使用高度缓存
- 避免在Cell中使用透明视图
- 图片异步加载和缓存

---

## 常见问题

### Q1: Cell重用导致数据错乱怎么办？

**A:** 
- 在`cellForRowAtIndexPath:`中完整配置Cell的所有数据
- 在`prepareForReuse`中重置可能变化的状态
- 对于异步加载的数据（如图片），使用`tag`或`weak`引用避免错乱

### Q2: 动态高度计算很慢怎么办？

**A:**
- 使用高度缓存，避免重复计算
- 使用模板Cell计算，而不是创建新Cell
- 使用`estimatedRowHeight`优化初始渲染
- 对于固定部分，可以预先计算

### Q3: 滚动时出现卡顿怎么优化？

**A:**
- 检查是否在主线程做了耗时操作
- 减少Cell的视图层级
- 使用高度缓存
- 图片异步加载和缓存
- 避免使用透明视图
- 使用Instruments的Time Profiler定位问题

### Q4: 如何实现分组列表？

**A:**
- 实现`numberOfSectionsInTableView:`返回分组数
- 在`numberOfRowsInSection:`中返回每个分组的行数
- 使用`titleForHeaderInSection:`设置分组标题
- 使用`viewForHeaderInSection:`自定义分组头部

---

## 总结

UITableView是iOS开发中最常用的组件之一，掌握以下要点：

1. **数据源和代理**：理解两者的职责分工
2. **Cell重用**：理解重用机制的原理和最佳实践
3. **高度计算**：掌握固定高度和动态高度的实现方式
4. **性能优化**：掌握各种性能优化技巧
5. **最佳实践**：遵循iOS开发的最佳实践

通过本主题的学习，应该能够：
- 熟练使用UITableView实现各种列表
- 理解Cell重用机制的原理
- 掌握性能优化的方法
- 能够解决常见的性能问题
