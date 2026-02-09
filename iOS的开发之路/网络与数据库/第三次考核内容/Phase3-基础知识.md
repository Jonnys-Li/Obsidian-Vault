# 第3阶段：基础知识

本文档按模块系统梳理**数据持久化与网络编程**所涉及的概念、原理与关键 API，便于从零巩固理论。按天学习与示例见 [Day30-31-本地存储](Day30-31-本地存储.md) 至 [Day40-第3阶段考核](Day40-第3阶段考核.md)。

---

## 1. 本地存储

### 1.1 沙盒

iOS 应用运行在**沙盒**中，只能访问自己目录下的文件，无法直接读写其他应用或系统目录。

| 目录 | 路径获取 | 用途 | 是否备份 |
|------|----------|------|----------|
| **Documents** | `NSDocumentDirectory` | 用户生成、需长期保存的内容（如用户文档、导出文件） | 是 |
| **Library/Caches** | `NSCachesDirectory` | 缓存，可重新下载的数据（图片、接口缓存等） | 否 |
| **Library/Preferences** | 多通过 NSUserDefaults 使用 | 偏好设置 | 是 |
| **tmp** | `NSTemporaryDirectory()` | 临时文件，系统可能随时清理 | 否 |

**路径获取示例**：

```objc
NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
NSString *tmpPath = NSTemporaryDirectory();
```

**选目录原则**：用户数据、需备份的放 Documents；可重新下载或仅作缓存的放 Caches；临时计算中间结果放 tmp。不要把可重新下载的大文件放在 Documents，否则备份慢且可能被 App Store 审核关注。

### 1.2 文件系统（NSFileManager）

- **创建目录**：`createDirectoryAtPath:withIntermediateDirectories:attributes:error:`
- **写文件**：`NSData` 的 `writeToFile:atomically:` 或 `NSFileHandle`
- **读文件**：`[NSData dataWithContentsOfFile:]` 或 `NSFileManager` 的 `contentsAtPath:`
- **判断存在 / 删除**：`fileExistsAtPath:`、`removeItemAtPath:error:`

根据数据性质选择 Documents / Caches / tmp，见上表。

### 1.3 NSUserDefaults

- **存储介质**：底层是 plist 文件，存在 Library/Preferences 下。
- **适用场景**：简单配置（主题、开关、上次选项、简单字符串/数字等）。
- **限制**：键值对体积不宜大；主线程同步读写；只能存 plist 兼容类型（NSString、NSNumber、NSData、NSArray、NSDictionary 等）；自定义对象需转成上述类型或归档为 Data。
- **常用 API**：`[NSUserDefaults standardUserDefaults]`，`setObject:forKey:` / `objectForKey:`、`stringForKey:`、`boolForKey:` 等；`synchronize` 在现代系统上一般可省略，系统会适时写入。

### 1.4 Keychain（钥匙串）

- **用途**：存储密码、token、证书等**敏感信息**，系统级加密；可选择在卸载应用后仍保留（如同一开发者账号下新安装的 App 读取）。
- **API**：使用 **Security.framework** 的 `SecItemAdd`（增）、`SecItemCopyMatching`（查）、`SecItemDelete`（删）。参数较多（kSecClass、kSecAttrService、kSecAttrAccount、kSecValueData 等），通常封装成工具类。
- **注意**：同一项查询时 kSecClass、kSecAttrService、kSecAttrAccount 需与写入一致；查询时需指定 kSecReturnData、kSecMatchLimit 等。kSecAttrAccessible 控制何时可访问（如 kSecAttrAccessibleWhenUnlockedThisDeviceOnly）。identifier 建议用 bundleId + 业务 key，避免与其他应用冲突。

### 1.5 选型对比

| 场景 | 推荐方式 |
|------|----------|
| 用户设置、开关、简单配置 | NSUserDefaults |
| 密码、token、敏感信息 | Keychain |
| 用户文档、导出文件 | Documents + 文件 API |
| 图片/数据缓存、可重建内容 | Caches + 文件 API |
| 临时计算中间结果 | tmp |

详见 [Day30-31-本地存储](Day30-31-本地存储.md)。

---

## 2. 数据库

### 2.1 SQLite

- **特点**：轻量级、无独立服务器、**文件型**数据库，内置于 iOS 系统。
- **在 iOS 中的位置**：数据库文件一般放在 Documents 或 Caches 目录，通过路径打开；使用第三方封装（如 FMDB）或系统 SQLite C API 操作。

### 2.2 SQL 基础

- **建表**：`CREATE TABLE IF NOT EXISTS 表名 (列名 类型, ...);`，常用类型 INTEGER、TEXT、REAL、BLOB。
- **插入**：`INSERT INTO 表名 (列1, 列2) VALUES (?, ?);`
- **查询**：`SELECT 列 FROM 表名 WHERE 条件 ORDER BY 列 LIMIT n;`
- **更新 / 删除**：`UPDATE 表名 SET 列=值 WHERE 条件;`，`DELETE FROM 表名 WHERE 条件;`

**参数化**：使用 `?` 占位符传参，避免 SQL 注入；FMDB 中 `executeUpdate:withArgumentsInArray:` 或可变参数形式。

### 2.3 FMDB 核心类

- **FMDatabase**：对应一个 SQLite 数据库文件，用于执行 SQL。**同一 FMDatabase 实例不宜在多线程间共享**，应在单线程使用，或通过 FMDatabaseQueue 间接使用。
- **FMResultSet**：查询结果集，逐行遍历，取列值如 `stringForColumn:`、`intForColumn:`、`longLongIntForColumn:` 等；用完后需 `close`。
- **FMDatabaseQueue**：用串行队列包装数据库操作，**多线程安全**。所有数据库访问放在 `inDatabase:` 或 `inTransaction:` 的 block 中，由 FMDB 串行执行。

### 2.4 事务（Transaction）

- **作用**：把多条 SQL 当作一个**原子操作**：要么全部成功（commit），要么全部回滚（rollback），保证一致性、减少多次写盘。
- **用法**：`[db beginTransaction];` → 执行多条语句 → `[db commit];` 或失败时 `[db rollback];`。FMDB 也提供 `inTransaction:` 的 block 形式，内部自动 commit/rollback。
- **何时用**：大批量插入/更新、多步操作必须同时成功或同时失败时使用。

### 2.5 线程安全

- **不要**在多线程中同时使用同一个 `FMDatabase` 实例，否则可能崩溃或数据异常。
- **正确做法**：使用 **FMDatabaseQueue**，所有数据库操作通过 `inDatabase:` 或 `inTransaction:` 入队，由 FMDB 串行执行，保证线程安全。

### 2.6 设计与优化

- **主键**：每表建议有主键（如 INTEGER PRIMARY KEY AUTOINCREMENT），便于唯一标识与关联。
- **索引**：对常出现在 WHERE、ORDER BY、JOIN 条件中的列建索引，可显著加速查询；索引会占用空间并增加写入成本，写多读少时需权衡；避免在索引列上做函数或运算。
- **范式与反范式**：范式减少冗余、保证一致性；反范式通过适当冗余减少 JOIN、提升查询速度；移动端常采用适度反范式。
- **查询优化**：只 SELECT 需要的列（避免 SELECT *）；WHERE 尽量用索引列；大批量插入用事务；分页用 LIMIT + OFFSET 或游标。
- **迁移思路**：用 **版本号**（如 SQLite 的 PRAGMA user_version）记录当前 DB 版本；根据版本执行 ALTER TABLE 加列、或「备份旧表 → 建新表 → 拷贝数据 → 删旧表」。SQLite 的 ALTER TABLE 只支持有限操作（如 ADD COLUMN），改类型、删列需通过重建表实现。

详见 [Day32-33-数据库基础](Day32-33-数据库基础.md)、[Day34-数据库设计与优化实践](Day34-数据库设计与优化实践.md)。

---

## 3. HTTP/HTTPS 与 NSURLSession

### 3.1 HTTP

- **请求结构**：请求行（方法 + URL + 协议版本）+ 请求头 + 空行 + 可选的 Body。
- **响应结构**：状态行（版本 + 状态码 + 原因短语）+ 响应头 + 空行 + Body。
- **常用方法**：GET（取资源）、POST（提交数据）、PUT、DELETE 等。
- **常见状态码**：200 成功、201 创建、400 客户端错误、401 未授权、404 未找到、500 服务端错误等。
- **常用 Header**：请求侧 Host、Content-Type、Content-Length、Authorization、User-Agent；响应侧 Content-Type、Content-Length、Cache-Control 等。

### 3.2 HTTPS

- **HTTPS = HTTP over TLS**：在 HTTP 之下增加 TLS 加密层，保证传输机密性与完整性。
- **证书**：用于验证服务端身份，防止中间人篡改；iOS 默认会校验证书。
- **ATS（App Transport Security）**：默认只允许 HTTPS；若需允许某 HTTP 域名，需在 Info.plist 配置例外，生产环境慎用；不要随意关闭证书校验。

### 3.3 NSURLSession

- **角色**：系统提供的网络 API，用于发起 HTTP/HTTPS 请求，支持 data task、upload task、download task。
- **创建**：`[NSURLSession sharedSession]` 或使用 `NSURLSessionConfiguration` 自定义（超时、缓存策略等）。
- **发起请求**：构造 `NSURLRequest` 或 `NSMutableURLRequest`（设置 URL、HTTPMethod、allHTTPHeaderFields、HTTPBody），再调用 `dataTaskWithRequest:completionHandler:`；在 completionHandler 中处理 NSData、NSURLResponse（可转为 NSHTTPURLResponse 读状态码与 Header）。
- **注意**：completionHandler 可能在子线程回调，更新 UI 需切回主线程（如 dispatch_async(dispatch_get_main_queue(), ...)）。

详见 [Day35-HTTP-HTTPS协议基础](Day35-HTTP-HTTPS协议基础.md)。

---

## 4. AFNetworking

### 4.1 整体架构

- **基于 NSURLSession**：对 data/upload/download task 进行封装，提供更便捷的 API。
- **AFHTTPSessionManager**：最常用入口，负责发 HTTP 请求，支持 GET/POST 等；可配置 baseURL、requestSerializer、responseSerializer。
- **AFURLSessionManager**：更底层，管理 NSURLSession 与 task；AFHTTPSessionManager 在其之上增加 HTTP 便捷方法。
- **序列化**：AFJSONRequestSerializer / AFJSONResponseSerializer 等，负责请求体与响应体的序列化/反序列化。
- **安全**：AFSecurityPolicy 可配置证书校验、允许自签名等（生产环境慎用放宽校验）。

### 4.2 核心类与调用链

- 创建 AFHTTPSessionManager → 设置 baseURL、requestSerializer、responseSerializer → 调用 `GET:parameters:headers:progress:success:failure:` 或 `POST:...` 等。
- 内部构造 NSURLRequest、创建 dataTask，在系统 completion 中通过 responseSerializer 解析响应，再回调 success 或 failure。

### 4.3 封装要点

- **统一 BaseURL**：避免每个接口写完整 URL；注意 baseURL 末尾是否带 `/` 与 path 是否以 `/` 开头会影响最终 URL。
- **通用 Header**：如 Token、AppVersion、Content-Type 在 manager 或 requestSerializer 中统一设置。
- **超时**：通过 NSURLSessionConfiguration 或 requestSerializer 的 timeout 设置。
- **错误与状态码**：可根据 HTTP 状态码（如 401、500）做统一处理（如 401 登出）；可封装一层把非 2xx 转为 NSError 走失败回调。
- **回调形式**：block（success/failure）最常用；AFNetworking 默认在主线程回调。

详见 [Day36-AFNetworking源码与封装](Day36-AFNetworking源码与封装.md)。

---

## 5. 网络数据处理

### 5.1 断点续传

- **原理**：HTTP 支持 **Range 请求**（请求头 `Range: bytes=start-end`），服务端返回 206 与对应片段；客户端把已下载部分与本次片段拼接成完整文件。
- **NSURLSessionDownloadTask**：取消时通过 `cancelByProducingResumeData:` 可得到 **resumeData**；再次创建 task 时使用 `downloadTaskWithResumeData:` 可从断点继续。需将 resumeData **持久化**（如写入 Caches），以便 App 重启后恢复下载。
- **注意**：resumeData 有时效性与系统版本依赖；部分服务端不支持 Range 则无法断点续传。

### 5.2 文件上传

- **multipart/form-data**：表单上传文件时的 Content-Type，用 boundary 分隔各字段与文件块。
- **NSURLSessionUploadTask**：可从文件 URL 或 NSData 上传；AFNetworking 的 `POST:parameters:constructingBodyWithBlock:` 中可用 `appendPartWithFileURL` 或 `appendPartWithFileData` 拼接 multipart。大文件上传注意内存，优先用文件流。

### 5.3 文件下载到沙盒

- 使用 NSURLSessionDownloadTask，在 completionHandler 中拿到**临时文件 URL**，用 NSFileManager 的 `moveItemAtURL:toURL:error:` 移动到 Documents 或 Caches，并记录最终路径。
- 大文件或可重新下载的文件建议放 Caches，避免占用备份空间。

### 5.4 JSON 解析

- **NSJSONSerialization**：`JSONObjectWithData:options:error:` 将 NSData 解析为 NSDictionary 或 NSArray；`dataWithJSONObject:options:error:` 将对象序列化为 JSON Data。
- **字典转模型**：可手写 `initWithDictionary:` 或使用 MJExtension、YYModel 等；注意类型与 null/nil 判断，避免崩溃。

详见 [Day37-38-网络数据处理](Day37-38-网络数据处理.md)。

---

## 6. 网络层架构

### 6.1 分层思路

- **API 层**：定义接口路径（path）、参数、Method（GET/POST 等），可集中在一个 APIConfig 或按业务模块拆分。
- **业务层**：调用 API 层发起请求，解析响应，转成业务模型或直接回调业务数据。
- **数据层**：实际发请求的组件（如封装的 AFNetworkingManager），负责 BaseURL、Header、超时、错误转换、与 AFNetworking/NSURLSession 的对接。

### 6.2 请求封装与响应统一

- **请求**：URL 由 BaseURL + path 组成，可按环境切换 BaseURL；参数 GET 用 query、POST 用 body（JSON 或 form）；Method 在配置或请求对象中声明。
- **响应统一格式**：常见约定如 `{ "code": 0, "message": "ok", "data": { ... } }`，code 非 0 表示业务错误。网络层解析 code，非 0 时构造 NSError 或业务错误对象走失败回调；同时处理 HTTP 状态码（如 401 登出、500 提示）。成功时把 data 或整个 response 交给业务层。
- **可扩展性**：新接口只需新增 path/参数配置；多环境通过切换 BaseURL 或 Environment 枚举实现；封装类对外提供统一入口（如 request(path, params, success, failure) 或按业务划分的 login、fetchList 等）。

### 6.3 与 AFNetworking 的配合

- 封装类内部使用 AFHTTPSessionManager，对外提供简洁接口；请求取消可保存 NSURLSessionDataTask 在适当时机 cancel；回调线程需明确（通常主线程更新 UI）。

详见 [Day39-网络层架构设计与实践](Day39-网络层架构设计与实践.md)。

---

## 小结

- **本地存储**：沙盒（Documents/Caches/tmp）+ NSFileManager；轻量配置用 NSUserDefaults，敏感信息用 Keychain；按场景选型。
- **数据库**：SQLite 文件型；FMDB 中 FMDatabase 单线程、FMDatabaseQueue 多线程安全；事务保证原子性；设计注意主键、索引与迁移。
- **HTTP/HTTPS**：请求/响应结构、方法、状态码、Header；HTTPS 与 TLS、证书校验；NSURLSession 为系统网络基础。
- **AFNetworking**：基于 NSURLSession 的封装，AFHTTPSessionManager 为常用入口；封装时统一 BaseURL、Header、超时与错误处理。
- **网络数据处理**：断点续传（Range、resumeData）；上传用 multipart；下载到沙盒；JSON 用 NSJSONSerialization，模型转换可手写或第三方。
- **网络层架构**：API 层 / 业务层 / 数据层 分层；请求与响应/错误统一；便于扩展新接口与多环境。

配合 [Phase3-面试考点](Phase3-面试考点.md) 与 [Day40-第3阶段考核](Day40-第3阶段考核.md) 进行背诵与自测。
