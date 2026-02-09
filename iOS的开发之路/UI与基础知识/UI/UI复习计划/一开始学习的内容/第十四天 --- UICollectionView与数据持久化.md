## 今日学习内容
- UICollection *View* 相关内容
	1. 掌握基本的结构和常用属性
		- 层级结构：`UICollectionView` =`cell` +`Supplementary view` +`background`
		- 注册机制： 在CollectionView中，必须先调用`registerClass:forCellWithReuseIdentifier` 否则回在cellforItem时崩掉
		- 属性控制：`allowMutipleSection` ,` indexPathForSectedItems` 
	2. 实现UICollectionView DataSource和UIColelctionView Delegate协议
		- `DataSource` 负责什么？
			- section
			- IndexPath
			- ReusableCell
		- `Delegate` 负责怎么动
			- `didSelectItemAtIndexPath` 处理点击
			- FlowLayout： 动态决定item的size和间距
	3. 自定义Layout（Flow Layout与其他自定义Layout）
		- Flow Layout(流式布局)
			- `itemSize` :格子宽高
			- `minimumLineSpacing` :行间距
			- `minimumInteritemSpacing` :同一个行内格子间距
		- 自定义：通过继承`UICollectionViewLayout` 手动计算每一个Cell坐标
	4. 自定义Cell和SupplementaryView（header/footer）
		- **自定义Cell**：需注意重写`prepareForReuse` 来清理旧的状态
		- **SupplementaryView (Header/Footer)**：
			- 需要使用`viewForSupplementaryElementOfKind` 返回
			- `registerClass` 来注册
	5. 联系常见布局效果（瀑布流，网格等）
		- 网格布局
		- 瀑布流
		- 横向分页
- 数据持久化
	1. 掌握离线优先的核心策略
		- 学习先读缓存，后请求网络，最后更新缓存的逻辑链
		- 理解iOS沙盒结构
	2. 实现NSCoding的模型序列化
		- 在自定义模型中实现encodeWithCoder（打包）
		- 实现initWithCoder（解包）
		- 掌握Key-Value标签管理，确保编码解码键值对完全一致
	3. 掌握二进制转换和磁盘读写
		  - 使用NSKeyArchiver将复杂对象数组转化为NSData
		  - 使用NSKeyedUnarchiver还原数据，并处理文件不存在活解析失败的边界情况
		  - 掌握writeToFile：atomically：确保数据写入的安全性
	4. 数据一致性与智能合并
		- 实现侧滑删除时“内存，UI，磁盘”三位一体同步刷新
		- 利用NSMutableSet和userId唯一标识符，实现新旧数据合并去重，避免重读 

