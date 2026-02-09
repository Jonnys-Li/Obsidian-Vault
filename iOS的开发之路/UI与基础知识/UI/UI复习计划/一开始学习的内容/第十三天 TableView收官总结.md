## 学习内容
1. 掌握TableView的基本属性
2. 掌握基本的代理方法
3. 掌握自定义Cell的方法
4. Cell的复用
5. 成功制作综合运用demo--通讯录
## 脑图
- UITableView 完整知识体系
    - 基础概念
        - 最常用的列表控件，一维、可滚动行数据
	        - 继承自UIScrollerView
        - 两种风格
	        -  `UITableViewStylePlain` -->普通样式
	        - `UITableViewStyleGrouped` --> 分组样式，可以用来设置section之间的间距。
		    
        - 初始化
	        - `[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain]`
	        - Storyboard拖拽
	    - 设置delegate和datasource
		    - `self.tableView.delegate=self;` 
		    - `self.tableView.dataSource=self;` 
    - 常用属性
        - style：plain / grouped（初始化时决定）
        - rowHeight：固定行高
        - estimatedRowHeight：预估行高（自适应必备）
        - separatorStyle / separatorColor / separatorInset：分隔线设置
        - sectionHeaderHeight / sectionFooterHeight / estimatedSectionHeaderHeight
        - tableHeaderView / tableFooterView：全表头尾（如搜索栏）
        - backgroundView：空数据占位
        - allowsSelection / allowsMultipleSelection
        - isEditing / setEditing：编辑模式
        - 自适应高度关键：
	        -  `self.tableView.rowHeight = UITableViewAutomaticDimension;`
			- `self.tableView.estimatedRowHeight = 100.0;`
    - 代理与数据源（核心）
        - UITableViewDataSource（必须）
            - numberOfSections
	            - 有多少组（可以没有，没有默认一组）
            - numberOfRowsInSection
	            - 每组多少行（必须）
            - cellForRowAtIndexPath：
	            - 每一行都是什么元素（必须）
		        - dequeueReusableCell （cell复用的关键）+ configure
        - UITableViewDelegate（常用）
            - 高度：heightForRowAt / heightForHeaderInSection 等
            - 视图：viewForHeaderInSection / viewForFooterInSection
            - 点击：didSelectRowAt（+ deselectRowAt）
            - 预显示：willDisplay cell（懒加载）
        - 编辑相关
            - canEditRowAt
            - commit editingStyle（左滑删除）
            - trailingSwipeActionsConfiguration（自定义左滑按钮）
        - 移动行（拖拽排序）
            - canMoveRowAt
            - moveRowAt
    - 自定义 Cell 实践
        - 实现方法：纯代码 + 自定义子类
        - 使用懒加载，优化性能，防止性能浪费，解耦setter方法和getter方法
        - 添加 `configureWithContact`: 方法专门用于数据填充（推荐命名方式）
        - `prepareForReuse`：清空旧数据防重影
        - 布局：使用`Masonry`约束
        - 避免在 `cellForRowAtIndexPath `加子视图
        - 注册时使用 `registerClass:forCellReuseIdentifier`:
代码如下：
```objc
#import "LBWContactCellTableViewCell.h"
#import "LBWContact.h"
#import <Masonry/Masonry.h>

@interface LBWContactCellTableViewCell ()

// 1. 使用私有属性，保持接口整洁
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *initialLabel;

@end

@implementation LBWContactCellTableViewCell

#pragma mark - Initializer

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 只有初始化时才添加 UI 组件，避免重复创建
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Lazy Loading (懒加载)
// 使用懒加载可以使 setupUI 更加清晰，且确保控件在需要时才创建

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.backgroundColor = [UIColor systemGray6Color];
        _iconView.layer.cornerRadius = 20;
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)initialLabel {
    if (!_initialLabel) {
        _initialLabel = [[UILabel alloc] init];
        _initialLabel.textColor = [UIColor whiteColor];
        _initialLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        _initialLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _initialLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor darkTextColor];
    }
    return _nameLabel;
}

- (UILabel *)phoneLabel {
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.font = [UIFont systemFontOfSize:13];
        _phoneLabel.textColor = [UIColor grayColor];
    }
    return _phoneLabel;
}

#pragma mark - Setup Methods

- (void)setupUI {
    [self.contentView addSubview:self.iconView];
    [self.iconView addSubview:self.initialLabel]; // 将文字加在背景图上
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.phoneLabel];
}

- (void)setupConstraints {
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(40);
    }];

    [self.initialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.iconView);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(12);
        make.top.equalTo(self.iconView).offset(2);
        make.right.lessThanOrEqualTo(self.contentView).offset(-15); // 防御：文字过长不超出边界
    }];

    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.bottom.equalTo(self.iconView).offset(-2);
        make.right.equalTo(self.nameLabel);
    }];
}

#pragma mark - Setter

- (void)setContact:(LBWContact *)contact {
    _contact = contact;
    
    // 数据绑定
    self.nameLabel.text = contact.name ?: @"未知";
    self.phoneLabel.text = contact.phoneNumber ?: @"无电话号码";
    
    // 头像首字母处理
    if (contact.name.length > 0) {
        self.initialLabel.text = [[contact.name substringToIndex:1] uppercaseString];
    } else {
        self.initialLabel.text = @"?";
    }
    
    // 设置背景颜色
    self.iconView.backgroundColor = [self colorFromName:contact.name];
}

#pragma mark - Helper

- (UIColor *)colorFromName:(NSString *)name {
    if (!name || name.length == 0) return [UIColor lightGrayColor];
    
    // 使用 Hash 生成颜色是业内常用技巧，可以保持一致性
    NSUInteger hash = [name hash];
    CGFloat hue = (CGFloat)(hash % 256) / 256.0; // 0.0 ~ 1.0
    
    // 调低饱和度 (Saturation) 和 亮度 (Brightness) 可以避免颜色过于“扎眼”
    // 0.4~0.6 的饱和度通常会看起来更高级
    return [UIColor colorWithHue:hue saturation:0.5 brightness:0.8 alpha:1.0];
}

@end
```


### Cell的复用（本质是一个队列加入一个缓存区）：（重点）
- 核心步骤：
	1. 注册
		-  在ViewDidLoad中告诉TableView该创建那种类型的Cell，并绑定Reuse identifier
		- ```objc
		  -(void)viewDidLoad{
		  [super viewDidLoad];
		  [self.tableView registerClass:[MyCustomCell class]forCellReuseIdentifier:@"MyCellID"];
		  
		  }
		  ```
	2. 出队
		- 在代理方法中，管标识符要一个Cell
		- ```objc
		  -(UITabeViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
		  //系统先检查复用池，若没有闲置的Cell，会根据上面注册的类自动创建一个新的
		  MyCustomCell *cell=[tableView dequeueResableCellWithIdentifier:@"MyCellID" forIndexPath:indexPath];
		  //配置数据（重点：一定要覆盖所有状态）
		  cell.titileLabel.text=self.dataArray[indexPath.row];
		  return cell;
		  }
		  ```
- 问题-- 复用状态的污染
	- Cell被重复使用，容易因为在复用逻辑中没有还原状态导致属性莫名其妙的改变
	- 错误示范：
	- ```objc
	  if(indexPath.row==0)
	  {cell.backgroundColor=[UIColor redColor];
	  }
	  //没有处理else，就很可能导致不满足if条件的cell也变成红色
	  ```
	- 修复方法：
		- 加上else闭环
		- 在自定义cell中重写prepareForReuse
		- ```objc
		  // 在 MyCustomCell.m 中
- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 1. 重置 UI 状态
    self.imageView.image = nil;
    self.titleLabel.textColor = [UIColor blackColor];
    
    // 2. 取消网络请求（如果该 Cell 的图片还在下载中）
    [self.imageDownloadOperation cancel];
}
		  ```

## 明日计划
- **学习UICollectionView**
	- 掌握基本结构和常用属性
	- 实现UICollectionViewDataSource和UICollectionViewDelegate协议
	- 自定义Layout（系统FlowLayout及自定义Layout）
	- 自定义Cell和SupplementaryView（header/footer）
	- 练习常见布局效果（如瀑布流、网格等）