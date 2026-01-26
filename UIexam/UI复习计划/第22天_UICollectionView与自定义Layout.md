# 第22天：UICollectionView 与自定义 Layout

## 核心知识点总结

### 1. UICollectionView 基础

#### 数据源方法（UICollectionViewDataSource）
- `numberOfSectionsInCollectionView:` - 返回分组数量
- `collectionView:numberOfItemsInSection:` - 返回每个分组的Item数量
- `collectionView:cellForItemAtIndexPath:` - 返回Cell实例
- `collectionView:viewForSupplementaryElementOfKind:atIndexPath:` - 返回SupplementaryView

#### 代理方法（UICollectionViewDelegate）
- `collectionView:didSelectItemAtIndexPath:` - Item点击事件
- `collectionView:willDisplayCell:forItemAtIndexPath:` - Cell即将显示
- `collectionView:layout:sizeForItemAtIndexPath:` - Item大小（FlowLayout）

#### Cell 和 SupplementaryView
- **Cell**：显示主要内容，类似UITableView的Cell
- **SupplementaryView**：补充视图，如Header、Footer
- **DecorationView**：装饰视图，用于布局装饰

### 2. UICollectionViewFlowLayout

#### 流式布局
- 默认的布局方式，类似瀑布流
- 支持水平和垂直滚动
- 可以设置Item大小、间距、滚动方向等

#### 常用属性
```objc
layout.itemSize = CGSizeMake(100, 100);           // Item大小
layout.minimumLineSpacing = 10;                   // 行间距
layout.minimumInteritemSpacing = 10;              // 列间距
layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10); // 分组内边距
layout.scrollDirection = UICollectionViewScrollDirectionVertical; // 滚动方向
```

### 3. 自定义 Layout

#### 继承 UICollectionViewLayout
```objc
@interface CustomLayout : UICollectionViewLayout
@end
```

#### 必须实现的方法
- `prepareLayout` - 准备布局，计算所有Item的属性
- `layoutAttributesForElementsInRect:` - 返回指定区域内的所有Item属性
- `layoutAttributesForItemAtIndexPath:` - 返回指定Item的属性
- `collectionViewContentSize` - 返回内容大小

#### 布局属性（UICollectionViewLayoutAttributes）
- `frame` - Item的位置和大小
- `transform` - 变换（旋转、缩放等）
- `alpha` - 透明度
- `zIndex` - 层级

### 4. 瀑布流布局实现

#### 核心思路
- 维护每列的高度数组
- 每次添加Item时，选择最短的列
- 计算Item的位置和大小

---

## 面试题

### 基础题

#### 1. UICollectionView 和 UITableView 有什么区别？

**答案：**
- **布局方式**：UITableView只能垂直滚动，UICollectionView支持多种布局
- **Cell类型**：UITableView只有一种Cell，UICollectionView可以有多种Cell和SupplementaryView
- **灵活性**：UICollectionView更灵活，可以实现复杂的布局
- **使用场景**：UITableView适合列表，UICollectionView适合网格、瀑布流等

#### 2. UICollectionViewFlowLayout 的常用属性有哪些？

**答案：**
- `itemSize` - Item的大小
- `minimumLineSpacing` - 行间距（垂直滚动）或列间距（水平滚动）
- `minimumInteritemSpacing` - 列间距（垂直滚动）或行间距（水平滚动）
- `sectionInset` - 分组的内边距
- `scrollDirection` - 滚动方向（垂直或水平）
- `headerReferenceSize` - Header大小
- `footerReferenceSize` - Footer大小

#### 3. 什么是 SupplementaryView？如何使用？

**答案：**
SupplementaryView是UICollectionView的补充视图，如Header和Footer。
```objc
// 注册SupplementaryView
[collectionView registerClass:[HeaderView class] 
    forSupplementaryViewOfKind:UICollectionElementKindSectionHeader 
    withReuseIdentifier:@"Header"];

// 在数据源方法中返回
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView 
           viewForSupplementaryElementOfKind:(NSString *)kind 
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind 
                                                                  withReuseIdentifier:@"Header" 
                                                                         forIndexPath:indexPath];
        return header;
    }
    return nil;
}
```

#### 4. 如何实现自定义Layout？

**答案：**
1. 继承`UICollectionViewLayout`
2. 实现必须的方法：
   - `prepareLayout` - 准备布局
   - `layoutAttributesForElementsInRect:` - 返回可见区域的属性
   - `layoutAttributesForItemAtIndexPath:` - 返回指定Item的属性
   - `collectionViewContentSize` - 返回内容大小
3. 在`prepareLayout`中计算所有Item的布局属性
4. 缓存布局属性，提高性能

### 进阶题

#### 5. 自定义Layout的实现原理是什么？

**答案：**
1. **prepareLayout**：在布局开始前调用，计算所有Item的布局属性并缓存
2. **layoutAttributesForElementsInRect:**：返回指定矩形区域内的所有Item属性，用于显示可见的Item
3. **layoutAttributesForItemAtIndexPath:**：返回指定Item的属性，用于单个Item的布局
4. **collectionViewContentSize**：返回整个内容的大小，用于设置滚动范围
5. **shouldInvalidateLayoutForBoundsChange:**：当bounds改变时是否重新布局

#### 6. 如何实现瀑布流布局？

**答案：**
核心思路：
1. 维护每列的高度数组
2. 在`prepareLayout`中遍历所有Item
3. 对每个Item，选择最短的列
4. 计算Item的位置（x = 列索引 × 列宽，y = 该列当前高度）
5. 更新该列的高度
6. 缓存所有Item的布局属性

```objc
- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger columnCount = 2;
    CGFloat itemWidth = (self.collectionView.bounds.size.width - (columnCount + 1) * 10) / columnCount;
    NSMutableArray *columnHeights = [NSMutableArray arrayWithCapacity:columnCount];
    for (NSInteger i = 0; i < columnCount; i++) {
        [columnHeights addObject:@(10)]; // 初始高度
    }
    
    NSMutableArray *attributesArray = [NSMutableArray array];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i = 0; i < itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        // 选择最短的列
        NSInteger shortestColumn = 0;
        CGFloat shortestHeight = [columnHeights[0] floatValue];
        for (NSInteger j = 1; j < columnCount; j++) {
            if ([columnHeights[j] floatValue] < shortestHeight) {
                shortestHeight = [columnHeights[j] floatValue];
                shortestColumn = j;
            }
        }
        
        // 计算Item高度（这里简化，实际应该根据数据计算）
        CGFloat itemHeight = 100 + arc4random() % 100;
        
        // 创建布局属性
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(10 + shortestColumn * (itemWidth + 10), 
                                     [columnHeights[shortestColumn] floatValue], 
                                     itemWidth, 
                                     itemHeight);
        
        [attributesArray addObject:attributes];
        
        // 更新列高度
        columnHeights[shortestColumn] = @([columnHeights[shortestColumn] floatValue] + itemHeight + 10);
    }
    
    self.layoutAttributesArray = attributesArray;
    
    // 计算内容大小
    CGFloat maxHeight = 0;
    for (NSNumber *height in columnHeights) {
        maxHeight = MAX(maxHeight, [height floatValue]);
    }
    self.contentSize = CGSizeMake(self.collectionView.bounds.size.width, maxHeight);
}
```

#### 7. 如何优化自定义Layout的性能？

**答案：**
1. **缓存布局属性**：在`prepareLayout`中计算并缓存所有属性
2. **按需计算**：只计算可见区域的属性（对于大量数据）
3. **避免重复计算**：使用`shouldInvalidateLayoutForBoundsChange:`控制何时重新布局
4. **使用estimatedItemSize**：提供估算大小，优化初始渲染
5. **减少属性对象创建**：复用布局属性对象

#### 8. layoutAttributesForElementsInRect: 的作用是什么？

**答案：**
- 返回指定矩形区域内的所有Item的布局属性
- UICollectionView使用这个方法获取可见区域的Item属性
- 只返回可见区域的属性，可以提高性能
- 对于大量数据，可以只计算可见区域的属性，而不是所有Item

### 原理题

#### 9. UICollectionView 的布局流程是什么？

**答案：**
1. **准备阶段**：调用`prepareLayout`，计算所有Item的布局属性
2. **查询阶段**：调用`layoutAttributesForElementsInRect:`获取可见区域的属性
3. **应用阶段**：UICollectionView根据属性设置每个Cell的frame
4. **更新阶段**：当滚动或数据变化时，可能调用`shouldInvalidateLayoutForBoundsChange:`判断是否需要重新布局

#### 10. 如何实现布局的动画和过渡？

**答案：**
1. **实现初始和最终布局**：创建两个Layout对象，分别表示初始和最终状态
2. **使用UICollectionViewTransitionLayout**：系统提供的过渡布局类
3. **实现自定义过渡**：继承`UICollectionViewTransitionLayout`，实现`layoutAttributesForElementsInRect:`
4. **使用动画**：在过渡过程中，根据进度插值计算中间状态的属性

---

## 实操题

### 实操题1：实现基础CollectionView

#### 需求描述
实现一个图片网格列表，使用UICollectionView显示多张图片。

#### 实现步骤

1. **创建CollectionView**
```objc
- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
    [self.view addSubview:self.collectionView];
}
```

2. **实现数据源方法**
```objc
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    [cell configureWithImageURL:self.imageURLs[indexPath.item]];
    return cell;
}
```

#### 关键代码

```objc
// ImageCell.h
@interface ImageCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
- (void)configureWithImageURL:(NSString *)imageURL;
@end
```

#### 性能优化点
- 使用Cell重用机制
- 图片异步加载
- 合理设置Item大小和间距

---

### 实操题2：实现自定义瀑布流布局

#### 需求描述
实现一个自定义的瀑布流布局，支持不同高度的Cell。

#### 实现步骤

1. **创建自定义Layout类**
```objc
// WaterfallLayout.h
@interface WaterfallLayout : UICollectionViewLayout
@property (nonatomic, assign) NSInteger columnCount; // 列数
@property (nonatomic, assign) CGFloat itemSpacing;   // Item间距
@end
```

2. **实现布局方法**
```objc
// WaterfallLayout.m
@interface WaterfallLayout ()
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributesArray;
@property (nonatomic, assign) CGSize contentSize;
@end

- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger columnCount = self.columnCount;
    CGFloat spacing = self.itemSpacing;
    CGFloat collectionViewWidth = self.collectionView.bounds.size.width;
    CGFloat itemWidth = (collectionViewWidth - (columnCount + 1) * spacing) / columnCount;
    
    // 初始化每列的高度
    NSMutableArray *columnHeights = [NSMutableArray arrayWithCapacity:columnCount];
    for (NSInteger i = 0; i < columnCount; i++) {
        [columnHeights addObject:@(spacing)];
    }
    
    // 计算所有Item的布局属性
    self.layoutAttributesArray = [NSMutableArray array];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i = 0; i < itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        // 找到最短的列
        NSInteger shortestColumn = 0;
        CGFloat shortestHeight = [columnHeights[0] floatValue];
        for (NSInteger j = 1; j < columnCount; j++) {
            CGFloat height = [columnHeights[j] floatValue];
            if (height < shortestHeight) {
                shortestHeight = height;
                shortestColumn = j;
            }
        }
        
        // 获取Item高度（这里需要从delegate获取，简化处理）
        CGFloat itemHeight = [self.delegate collectionView:self.collectionView 
                                                     layout:self 
                                   heightForItemAtIndexPath:indexPath 
                                                     width:itemWidth];
        
        // 创建布局属性
        UICollectionViewLayoutAttributes *attributes = 
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(spacing + shortestColumn * (itemWidth + spacing),
                                     [columnHeights[shortestColumn] floatValue],
                                     itemWidth,
                                     itemHeight);
        
        [self.layoutAttributesArray addObject:attributes];
        
        // 更新列高度
        columnHeights[shortestColumn] = @([columnHeights[shortestColumn] floatValue] + itemHeight + spacing);
    }
    
    // 计算内容大小
    CGFloat maxHeight = 0;
    for (NSNumber *height in columnHeights) {
        maxHeight = MAX(maxHeight, [height floatValue]);
    }
    self.contentSize = CGSizeMake(collectionViewWidth, maxHeight);
}
```

3. **实现其他必须的方法**
```objc
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attributes in self.layoutAttributesArray) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributesArray addObject:attributes];
        }
    }
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutAttributesArray[indexPath.item];
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}
```

#### 关键代码

```objc
// 定义代理协议，用于获取Item高度
@protocol WaterfallLayoutDelegate <NSObject>
- (CGFloat)collectionView:(UICollectionView *)collectionView 
                   layout:(WaterfallLayout *)layout 
 heightForItemAtIndexPath:(NSIndexPath *)indexPath 
                    width:(CGFloat)width;
@end
```

#### 性能优化点
- 在`prepareLayout`中一次性计算所有属性并缓存
- 在`layoutAttributesForElementsInRect:`中只返回可见区域的属性
- 使用`shouldInvalidateLayoutForBoundsChange:`控制重新布局的时机

---

### 实操题3：实现带Header和Footer的CollectionView

#### 需求描述
实现一个带分组Header和Footer的CollectionView。

#### 实现步骤

1. **配置FlowLayout**
```objc
UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 50);
layout.footerReferenceSize = CGSizeMake(self.view.bounds.size.width, 50);
```

2. **注册SupplementaryView**
```objc
[collectionView registerClass:[SectionHeaderView class] 
    forSupplementaryViewOfKind:UICollectionElementKindSectionHeader 
    withReuseIdentifier:@"Header"];

[collectionView registerClass:[SectionFooterView class] 
    forSupplementaryViewOfKind:UICollectionElementKindSectionFooter 
    withReuseIdentifier:@"Footer"];
```

3. **实现数据源方法**
```objc
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView 
           viewForSupplementaryElementOfKind:(NSString *)kind 
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind 
                                                                          withReuseIdentifier:@"Header" 
                                                                                 forIndexPath:indexPath];
        header.titleLabel.text = [NSString stringWithFormat:@"Section %ld", indexPath.section];
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        SectionFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind 
                                                                          withReuseIdentifier:@"Footer" 
                                                                                 forIndexPath:indexPath];
        return footer;
    }
    return nil;
}
```

#### 关键代码

```objc
// SectionHeaderView.h
@interface SectionHeaderView : UICollectionReusableView
@property (nonatomic, strong) UILabel *titleLabel;
@end
```

#### 性能优化点
- SupplementaryView也支持重用
- 在`prepareForReuse`中重置状态

---

## 常见问题

### Q1: 如何实现水平滚动的CollectionView？

**A:**
```objc
UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
```

### Q2: 自定义Layout时，如何实现Item的动画效果？

**A:**
- 在`initialLayoutAttributesForAppearingItemAtIndexPath:`中返回初始属性
- 在`finalLayoutAttributesForDisappearingItemAtIndexPath:`中返回最终属性
- UICollectionView会自动创建动画

### Q3: 如何优化大量Item的CollectionView性能？

**A:**
- 在`layoutAttributesForElementsInRect:`中只返回可见区域的属性
- 使用`estimatedItemSize`提供估算大小
- 合理使用Cell重用
- 图片异步加载和缓存

### Q4: 如何实现分组的不同布局？

**A:**
- 使用`UICollectionViewDelegateFlowLayout`的代理方法
- 为不同分组返回不同的Item大小和间距
- 或者使用自定义Layout，在`prepareLayout`中根据分组设置不同的布局

---

## 总结

UICollectionView是iOS开发中非常灵活的组件，掌握以下要点：

1. **基础使用**：数据源方法、代理方法、Cell和SupplementaryView
2. **FlowLayout**：流式布局的配置和使用
3. **自定义Layout**：理解布局原理，实现自定义布局
4. **性能优化**：缓存布局属性，按需计算
5. **最佳实践**：合理使用Cell重用，优化滚动性能

通过本主题的学习，应该能够：
- 熟练使用UICollectionView实现各种布局
- 理解自定义Layout的实现原理
- 实现瀑布流等复杂布局
- 优化CollectionView的性能
