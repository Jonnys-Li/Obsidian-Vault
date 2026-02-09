# 第3阶段：实现原理与代码要点

本文档讲清楚**底层怎么实现的**、**代码里有什么坑/要注意什么**、**结合场景怎么做**，面向“知其然且知其所以然”。概念与 API 见 [Phase3-基础知识](Phase3-基础知识.md)；配套示例见 `NetWork/Examples/` 下各 Day 目录。

---

## 1. 本地存储：底层与代码要点

### 1.1 NSUserDefaults 底层

- **存储介质**：对应 **plist 文件**，位于 `Library/Preferences/` 下（通常以 bundleId 命名）。读写时先走**内存缓存**，写盘由系统在适当时机**异步**触发，因此并非每次 `setObject` 都会立刻写磁盘。
- **synchronize**：调用后会**同步**将内存中的改动写入 plist。现代系统（iOS 12+）会在进程挂起等时机自动写盘，一般不必主动调；若需“立刻落盘”（如子线程写入后希望主线程马上读到），可主动调用一次，但主线程调用会阻塞。
- **主线程大量写入**：在主线程频繁或大量写 UserDefaults 会触发 plist 的序列化与 IO，**阻塞 UI**；plist 体积过大时读写都会变慢。因此不建议在主线程“狂写”，也不建议存大对象或大量键值对。
- **子线程读写**：子线程 `setObject` 后，主线程 `objectForKey` 不一定立刻读到刚写的值（因为写盘是异步的）；若需跨线程一致，可主动 `synchronize` 或约定统一在主线程读写。

### 1.2 Keychain 底层

- **通信方式**：通过 **Security.framework** 与系统 **Keychain 服务**（daemon）通信，应用不直接读写文件，数据由系统加密存储。
- **唯一性**：同一组 **kSecAttrService + kSecAttrAccount**（及 kSecClass）在 Keychain 中唯一。重复调用 `SecItemAdd` 添加相同 service+account 会返回“已存在”错误。
- **更新**：实现“更新”需先 **SecItemDelete** 再 **SecItemAdd**；部分系统/场景下也可用 `SecItemUpdate`（需查文档确认可用性）。
- **kSecAttrAccessible**：控制**何时可访问**、**是否可备份到其他设备**。例如：
  - `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`：仅设备解锁时可访问，且**仅本机**、不随备份迁移到新设备（换机后新设备没有该项）。
  - `kSecAttrAccessibleWhenUnlocked`：可随备份迁移，换机后新设备能恢复。
- 若希望“换新手机后仍保持登录态”，需使用会参与备份的选项；若希望“仅本机、不随备份”，用 ThisDeviceOnly 系列。

### 1.3 文件读写底层与注意点

- **writeToFile:atomically:YES**：会先写到**临时文件**，成功后再**替换**目标文件，从而避免“写一半崩溃”导致原文件损坏。atomically:NO 则直接写目标文件，崩溃可能丢数据。
- **大文件**：用 `[NSData dataWithContentsOfFile:]` 会一次性把整个文件读入内存，大文件易 OOM。应使用 **NSFileHandle** 或流式读写，或分段读。
- **选目录**：用户文档、需备份的放 Documents；可重新下载的缓存放 Caches（不备份，且系统可能清理）；误把大缓存放 Documents 会导致备份膨胀、审核风险。

### 1.4 代码关注点小结

- UserDefaults：不存大对象、不在主线程大量写入；子线程写后若主线程要立刻读，可 synchronize 或统一主线程读写。
- Keychain：service/account 唯一；更新用“先删后增”；根据“是否换机保留”选 kSecAttrAccessible。
- 文件：大文件用流式读写；写用 atomically:YES；Documents 与 Caches 别用反。

### 1.5 场景：怎么做

| 场景 | 怎么做 |
|------|--------|
| **安全存 token** | 存 Keychain；kSecAttrAccessible 选 WhenUnlockedThisDeviceOnly（仅本机）或 WhenUnlocked（可备份）；读写封装成工具类（如 [KeychainHelper](NetWork/Examples/Day30_31_LocalStorage/KeychainHelper.m)）；请求时从 Keychain 取并放到 Header。 |
| **换设备后登录态丢失** | 检查 Keychain 的 kSecAttrAccessible：若用了 ThisDeviceOnly，换机不会迁移；若希望换机保留，改用可备份的选项。 |
| **配置在 App 与扩展共享** | 使用 **App Group**，在同一 Group 内共享容器；NSUserDefaults 用 `initWithSuiteName:` 指定 group id；Keychain 也可配合 keychain access group 做共享。 |

---

## 2. 数据库：底层与代码要点

### 2.1 SQLite / FMDB 底层

- **FMDatabase**：内部持有一个 **sqlite3** 连接指针，所有 SQL 通过该连接执行。SQLite 的**同一连接在多线程下并发使用是不安全的**（文档明确说明），因此同一 FMDatabase 实例不宜在多个线程同时调用。
- **FMDatabaseQueue**：内部使用一个**串行 dispatch_queue**。每次调用 `inDatabase:` 时，传入的 block 被放到该队列执行；执行时从“池”中取到或创建 FMDatabase，在该队列中执行 SQL，执行完毕再归还。这样**同一时刻只有一个线程**在使用某个 db 连接，从而保证线程安全。
- **事务**：对应 SQLite 的 **BEGIN / COMMIT / ROLLBACK**。开启事务后，多次写操作会先缓存在内存/日志中，commit 时一次性刷盘，可**大幅减少磁盘同步次数**，批量插入时性能提升明显。若中途异常，必须 **rollback**，否则可能造成数据库锁或数据不一致。

### 2.2 代码关注点

- **写用 executeUpdate，查用 executeQuery**：写返回 BOOL，查返回 FMResultSet；不要混用。
- **FMResultSet**：用完后要 **close**，否则可能占用资源或影响后续操作。
- **多线程**：只用 **FMDatabaseQueue**，在 block 内拿 db 执行；不要在多线程间共享同一个 FMDatabase。
- **迁移**：加列或改结构前要有**版本号**（如 PRAGMA user_version）；复杂迁移（改类型、删列）需重建表；迁移前最好备份或做好可回滚方案。

### 2.3 场景：怎么做

| 场景 | 怎么做 |
|------|--------|
| **大批量插入卡顿** | 用**事务**：beginTransaction → 循环 insert → commit（或失败时 rollback）；并把耗时操作放到 **FMDatabaseQueue** 的 inDatabase 中，避免阻塞主线程。 |
| **多线程同时写崩溃** | 不要多线程共享 FMDatabase；改用 **FMDatabaseQueue**，所有写操作都通过 inDatabase 或 inTransaction 入队。 |
| **表结构要加字段** | 用 **版本号 + 迁移**：读取当前 user_version，若小于新版本则执行 ALTER TABLE ADD COLUMN 或“备份旧表→建新表→拷贝数据→删旧表”，最后更新 user_version。示例见 [NoteTableManager](NetWork/Examples/Day34_DatabaseDesign/NoteTableManager.m) 的迁移逻辑。 |

---

## 3. 网络：NSURLSession 与 AFNetworking 底层与代码要点

### 3.1 NSURLSession 底层

- **体系**：基于系统的 **URL Loading System**，支持 delegate 回调和 completionHandler 回调两种方式。
- **completionHandler 线程**：由创建 session 时传入的 **delegateQueue** 决定。若未设置，系统可能使用**非主线程**回调，因此在 completionHandler 里更新 UI 前需确认线程，通常要 `dispatch_async(dispatch_get_main_queue(), ...)` 或创建 session 时指定 delegateQueue 为主队列。
- **Task 生命周期**：task 创建后由 session 持有；**cancel** 后不可复用；请求未完成时若 VC 已销毁，应主动 cancel 避免无效回调和资源占用。

### 3.2 AFNetworking 底层

- **与 NSURLSession 关系**：AF 内部创建并持有 **NSURLSession**，发请求时创建 **NSURLSessionDataTask**（或 upload/download task）。
- **请求体**：**requestSerializer**（如 AFJSONRequestSerializer）把传入的 parameters 转成 URL query（GET）或 HTTP body（POST 的 JSON）；设置 Content-Type 等 Header。
- **响应体**：收到 NSData 后，由 **responseSerializer**（如 AFJSONResponseSerializer）调用 **NSJSONSerialization** 等解析成 NSDictionary/NSArray，再在**主线程**回调 success 或 failure（AF 默认将回调派发到主队列）。
- **证书**：AFSecurityPolicy 负责校验证书；生产环境不要随意关闭校验或信任自签名。

### 3.3 代码关注点

- **block 与 self**：在 success/failure block 里直接使用 **self** 可能造成**循环引用**（self → manager → task → block → self）。应使用 `__weak typeof(self) wself = self`，在 block 内用 wself。
- **请求取消**：保存返回的 **NSURLSessionDataTask**，在页面消失或新请求发起前调用 **cancel**。
- **401/500 统一处理**：在**封装层**判断 HTTP 状态码，401 时发通知或统一回调“需要重新登录”，由根 VC 或路由弹登录页，而不是每个调用方都写一遍判断。
- **证书错误**：排查 ATS 配置、服务端证书链、域名是否与证书一致、是否被代理篡改。

### 3.4 场景：怎么做

| 场景 | 怎么做 |
|------|--------|
| **接口 401 要在网络层统一弹登录页** | 在封装的 failure 或 response 拦截里判断 statusCode == 401，发 NSNotification 或通过 delegate/block 通知“未授权”，由 AppDelegate 或路由统一 present 登录页；同时清除本地 token。 |
| **请求未完成时页面退出要取消** | 在 VC 的 dealloc 或 viewWillDisappear 里对当前页发起的 task 调用 cancel；若用 AF，保存 dataTask 引用并在适当时机 cancel。 |
| **证书错误怎么排查** | 检查 Info.plist 的 ATS；用 Safari 或 curl 验证服务端证书链；确认请求的域名与证书 CN/SAN 一致；若走代理，排除代理对证书的篡改。 |

---

## 4. 断点续传与文件传输：实现与代码要点

### 4.1 断点续传实现

- **HTTP Range**：请求头 `Range: bytes=start-end`，服务端支持则返回 **206** 和对应片段；客户端把已下载文件与本次片段拼接。若服务端不支持 Range，无法做断点续传。
- **resumeData**：对 **NSURLSessionDownloadTask** 调用 **cancelByProducingResumeData:** 时，系统在 block 里返回 **resumeData**（内部状态数据）。之后用 **downloadTaskWithResumeData:** 创建新 task，即可从断点继续。resumeData 有时效和系统版本依赖，不宜长期依赖。
- **持久化**：将 resumeData 写入 **Caches** 等路径，App 被杀或重启后读取，若有则用 downloadTaskWithResumeData 恢复下载。
- **临时文件**：download 的 completionHandler 里拿到的是**临时文件 URL**，需用 **NSFileManager moveItemAtURL:toURL:** 移动到目标路径（如 Caches），否则临时文件可能被系统清理。

### 4.2 代码关注点

- 大文件下载目标路径用 **Caches**，避免 Documents 备份膨胀。
- 上传大文件时用**文件 URL** 或流式构造 body，避免整块 NSData 进内存导致 OOM。
- 示例：断点续传见 [ResumableDownloadHelper](NetWork/Examples/Day37_38_NetworkData/ResumableDownloadHelper.m)，上传见 [FileUploadHelper](NetWork/Examples/Day37_38_NetworkData/FileUploadHelper.m)。

### 4.3 场景：怎么做

| 场景 | 怎么做 |
|------|--------|
| **App 被杀后如何继续下载** | 下载过程中把 **resumeData** 持久化到 Caches；App 启动时检查是否存在未完成下载的 resumeData，若有则用 downloadTaskWithResumeData 恢复，并可选展示“继续下载”入口。 |
| **大文件上传 OOM** | 使用 **NSURLSessionUploadTask** 的 `uploadTaskWithRequest:fromFile:` 或 AF 的 appendPartWithFileURL，用文件流上传，避免把整个文件读成 NSData。 |

---

## 5. 网络层封装：怎么做与代码要点

### 5.1 统一错误与 401

- 在**封装层**（如 AF 的 success/failure 或自定义 response 拦截）里判断 **HTTP statusCode** 或 body 里的 **code**。
- 若 statusCode 非 2xx 或 code != 0，构造 **NSError** 或业务错误对象，统一走 **failure** 回调；业务层只处理 success/failure，不关心具体状态码。
- **401** 时：清除本地 token、发通知或统一回调“需要重新登录”，由统一入口（如根 VC、路由）弹登录页。

### 5.2 代码关注点

- **回调线程**：明确约定 success/failure 是否在主线程；若在子线程，业务层更新 UI 前需切主线程。
- **Task 持有与取消**：封装层可返回 task 供调用方 cancel；或内部按请求 key 管理 task，在适当时机统一 cancel。
- **BaseURL 与 path**：baseURL 末尾是否带 `/`、path 是否以 `/` 开头会影响最终 URL，需统一约定（如 baseURL 不带尾斜杠、path 以 `/` 开头）。

### 5.3 场景：怎么做

| 场景 | 怎么做 |
|------|--------|
| **新接口要加多种环境** | BaseURL 按配置或环境枚举切换（Debug/Release/预发）；封装类暴露 setBaseURL 或初始化时传入 environment。 |
| **所有请求都要带 token** | 在 **requestSerializer** 的 setValue:forHTTPHeaderField: 里统一设置 Authorization；或每次请求前从 Keychain 取 token，通过 AF 的 headers 参数或自定义 request 构造注入。示例思路见 [AFNetworkingManager](NetWork/Examples/Day36_AFNetworking/AFNetworkingManager.m) 的 setCommonHeaderValue。 |

---

## 小结

- **本地存储**：UserDefaults 内存缓存 + 异步写盘，synchronize 同步写；Keychain 通过 Security 与系统服务通信，kSecAttrAccessible 决定可访问时机与是否迁移；文件 atomically:YES 先写临时再替换；注意主线程不狂写、选对目录与 Keychain 属性。
- **数据库**：FMDatabase 单连接不宜多线程共享；FMDatabaseQueue 串行队列保证安全；事务对应 BEGIN/COMMIT/ROLLBACK，批量写必用；迁移用版本号 + ALTER 或重建表。
- **网络**：NSURLSession 的 completion 线程由 delegateQueue 决定；AF 用 requestSerializer/responseSerializer 转参与解析，默认主线程回调；block 里 weak self、请求取消、401 统一处理。
- **断点续传**：Range + resumeData 持久化 + 恢复时 downloadTaskWithResumeData；大文件用 Caches、上传用文件流。
- **网络层封装**：统一错误与 401、回调线程、task 取消、BaseURL 与 token 注入。

配合 [Phase3-面试题库](Phase3-面试题库.md) 做场景与原理题的自测。
