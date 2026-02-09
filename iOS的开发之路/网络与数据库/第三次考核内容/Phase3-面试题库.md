# 第3阶段：面试题库

本题库面向**理解实现、会设计、会排查**的深度考察，与 [Phase3-面试考点](Phase3-面试考点.md) 的概念型问答区分。题型包括**场景题、实现原理题、设计/实现题、代码关注题**，每题附参考答案要点。底层与代码细节见 [Phase3-实现原理与代码要点](Phase3-实现原理与代码要点.md)。

---

## 一、场景题（结合业务/问题排查）

### 1.1 本地存储

**题**：用户反馈“换了新手机后登录态没了”，你怎么排查？

**参考答案要点**：
- 先确认登录态是存在 **Keychain** 还是 UserDefaults。若在 Keychain，重点看 **kSecAttrAccessible**。
- 若用了 **kSecAttrAccessibleWhenUnlockedThisDeviceOnly**（或带 ThisDeviceOnly 的项），数据**不会随备份迁移到新设备**，换机后新设备上没有这条记录，属于预期行为。
- 若希望换机后仍保持登录态，应使用可参与备份的选项（如 `kSecAttrAccessibleWhenUnlocked`），并确保用户开启了 iCloud/ iTunes 备份。
- 同时排查：是否在 401 或登出时误删了 Keychain 项；是否新老 App 的 bundleId 或 Keychain access group 不一致导致读不到。

详见 [实现原理与代码要点 - 1.2 Keychain 底层](Phase3-实现原理与代码要点.md#12-keychain-底层)。

---

**题**：要做一个“设置”页，配置需在 App 与 Today 扩展里共享，你会怎么做？

**参考答案要点**：
- 使用 **App Group**：主 App 与 Today 扩展在 Xcode 中勾选同一 App Group（如 `group.com.xxx.app`），才能共享容器。
- **NSUserDefaults**：不用 standardUserDefaults，改用 `[[NSUserDefaults alloc] initWithSuiteName:@"group.com.xxx.app"]`，之后 setObject/objectForKey 的读写都在该共享容器内，主 App 与扩展都能访问。
- 若配置含敏感信息，可用 **Keychain** 并配置 **keychain access group**，使主 App 与扩展在同一 group 内共享 Keychain 项。
- 注意：扩展与主 App 是不同进程，读写时序上可能有延迟，若需“写后立刻在另一进程读到”，可配合 CFNotificationCenter 或 Darwin 通知做进程间通知。

---

### 1.2 数据库

**题**：用户反馈“保存很多条记录后 App 很卡”，可能原因与优化思路？

**参考答案要点**：
- **可能原因**：大批量插入时**未使用事务**，每条 insert 都触发一次磁盘同步；或在大批量写时放在**主线程**执行，阻塞 UI。
- **优化**：① 使用**事务**：beginTransaction → 循环 insert → commit（失败则 rollback），可大幅减少 IO。② 把数据库写操作放到**子线程**或 **FMDatabaseQueue** 的 inDatabase/inTransaction 中，避免阻塞主线程。③ 单次插入量特别大时，可分批 commit（如每 500 条一事务），平衡内存与性能。

详见 [实现原理与代码要点 - 2.3 场景](Phase3-实现原理与代码要点.md#23-场景怎么做)。

---

### 1.3 网络

**题**：接口返回 401，你希望在所有接口层统一处理（例如弹登录页），而不是每个请求都写一遍判断，怎么做？

**参考答案要点**：
- 在**网络封装层**（如 AF 的 failure 回调或自定义 response 拦截）里判断 **HTTP statusCode == 401**。
- 一旦是 401：① 清除本地 token（Keychain/UserDefaults）；② 通过 **NSNotification**、**delegate** 或**统一 block** 通知“需要重新登录”；③ 由**统一入口**（如 AppDelegate、根 VC、路由）present 登录页，而不是在每个调用方写 if (statusCode == 401)。
- 这样业务层只关心 success/failure，401 的 UI 与跳转逻辑集中在一处，易维护。

详见 [实现原理与代码要点 - 3.4 场景](Phase3-实现原理与代码要点.md#34-场景怎么做)。

---

**题**：用户反馈“在弱网下点击列表会卡住”，可能原因与解决思路？

**参考答案要点**：
- **可能原因**：请求未设置合理**超时**；列表请求**未取消**，页面已切换仍等待旧请求；**重复请求**（快速多次点击触发多次请求）；loading 或空白态不明确导致用户以为卡住。
- **解决**：① 设置 **timeoutInterval**，超时后走 failure。② 列表页在 **viewWillDisappear** 或 **dealloc** 里 **cancel** 当前列表的 dataTask，避免无效回调。③ 防重复：请求进行中禁用按钮或忽略重复点击。④ 明确 loading/空数据/错误态，给用户反馈。

---

### 1.4 断点续传

**题**：大文件下载到一半用户退到后台，App 被系统杀了，重新打开后希望继续下载，你会怎么设计？

**参考答案要点**：
- 在**取消或暂停**下载时，通过 **cancelByProducingResumeData:** 拿到 **resumeData**，并**持久化**到 Caches 目录（如按 URL 或任务 id 命名的文件）。
- App **启动时**检查是否存在“未完成的下载”（如本地有 resumeData 或未完成的临时文件），若有则读取 resumeData，用 **downloadTaskWithResumeData:** 恢复下载。
- 可选：在 UI 上提供“未完成下载”列表或“继续下载”入口。注意 resumeData 有时效与系统版本依赖，恢复失败时需降级为重新下载并清理无效 resumeData。

详见 [实现原理与代码要点 - 4.1 断点续传实现](Phase3-实现原理与代码要点.md#41-断点续传实现)。

---

## 二、实现原理题（底层怎么做的）

### 2.1 NSUserDefaults

**题**：synchronize 是同步还是异步？为什么不建议在主线程存大量数据？

**参考答案要点**：
- **synchronize**：是**同步**操作，会把当前内存中的键值对**立即写入** plist 文件；调用会阻塞当前线程直到写盘完成。
- 不在主线程存大量数据的原因：① 默认写盘是**异步**的，但若主动调 synchronize 或系统触发了写盘，会在当前线程做 plist 序列化与 IO，**主线程会阻塞 UI**。② 存大量数据会导致 plist 体积大，读写都变慢，进一步放大卡顿。所以应控制 UserDefaults 体积，且避免在主线程频繁或大量写入。

详见 [实现原理与代码要点 - 1.1 NSUserDefaults 底层](Phase3-实现原理与代码要点.md#11-nsuserdefaults-底层)。

---

### 2.2 Keychain

**题**：同一个 service+account 重复调用 SecItemAdd 会怎样？如何实现“更新”？

**参考答案要点**：
- **重复 SecItemAdd**：会返回 **errSecDuplicateItem**（已存在），添加失败。
- **实现更新**：先 **SecItemDelete** 删除同 service+account 的项，再 **SecItemAdd** 写入新值。部分系统也支持 **SecItemUpdate**（更新 kSecValueData 等），需查文档确认当前环境是否可用；通用做法是“先删后增”。

详见 [实现原理与代码要点 - 1.2 Keychain 底层](Phase3-实现原理与代码要点.md#12-keychain-底层)。

---

### 2.3 FMDB

**题**：FMDatabaseQueue 为什么能保证线程安全？内部大致怎么做的？

**参考答案要点**：
- **原因**：所有数据库访问都通过 **inDatabase:** / **inTransaction:** 的 block 提交到**同一个串行 dispatch_queue**，同一时刻**只有一个线程**在执行 block，即只有一个线程在用 FMDatabase，因此不会出现多线程并发操作同一 sqlite3 连接。
- **大致实现**：Queue 内部持有一个串行队列；inDatabase 时把 block 派发到该队列；执行时从内部“池”中取或创建 FMDatabase，在当前队列中执行 block 内的 SQL，执行完再归还，保证连接不被多线程同时使用。

详见 [实现原理与代码要点 - 2.1 SQLite / FMDB 底层](Phase3-实现原理与代码要点.md#21-sqlite--fmdb-底层)。

---

### 2.4 NSURLSession

**题**：dataTaskWithRequest 的 completionHandler 默认在哪个线程回调？更新 UI 要注意什么？

**参考答案要点**：
- **线程**：由创建 NSURLSession 时传入的 **delegateQueue** 决定。若未设置，系统可能使用**非主线程**（如内部工作队列）回调。
- **更新 UI**：在 completionHandler 里若直接更新 UI，可能不在主线程导致问题。应 **dispatch_async(dispatch_get_main_queue(), ^{ ... })** 切回主线程再更新 UI，或在创建 session 时设置 delegateQueue 为 **mainQueue**。

详见 [实现原理与代码要点 - 3.1 NSURLSession 底层](Phase3-实现原理与代码要点.md#31-nsurlsession-底层)。

---

### 2.5 AFNetworking

**题**：AF 的 success/failure 回调在哪个线程？内部是如何把 NSData 转成你拿到的 responseObject 的？

**参考答案要点**：
- **线程**：AF 默认把 success/failure **派发到主线程**（通过 AFURLSessionManager 等内部把系统回调派发到主队列），因此一般可直接在 block 里更新 UI。
- **Data → responseObject**：收到 NSData 后，由 **responseSerializer**（如 AFJSONResponseSerializer）处理：内部调用 **NSJSONSerialization JSONObjectWithData:...** 将 data 解析成 NSDictionary/NSArray，再作为 responseObject 传给 success block。若解析失败则走 failure。

详见 [实现原理与代码要点 - 3.2 AFNetworking 底层](Phase3-实现原理与代码要点.md#32-afnetworking-底层)。

---

## 三、设计/实现题（你怎么做）

### 3.1 设计：断点续传下载器

**题**：让你设计一个支持断点续传的下载器，你会考虑哪些点？

**参考答案要点**：
- **resumeData**：暂停/取消时用 **cancelByProducingResumeData:** 拿到并**持久化**（如 Caches）；恢复时用 **downloadTaskWithResumeData:**。
- **存储路径**：resumeData 存 Caches；下载完成后的文件也建议 Caches（大文件不占备份）。
- **进度**：通过 NSURLSessionDownloadTask 的 delegate 或 KVO 监听进度，回调给上层。
- **API 设计**：提供 start、pause、resume、cancel；可暴露进度 block 和完成/失败 block。
- **后台下载**：可选支持 NSURLSession 的 backgroundConfiguration，在后台继续下载。
- **服务端**：需支持 **Range** 请求，否则只能重新下；可先发 HEAD 或带 Range 的请求探测是否支持。

详见 [实现原理与代码要点 - 4](Phase3-实现原理与代码要点.md#4-断点续传与文件传输实现与代码要点)。

---

### 3.2 设计：安全存 token

**题**：如何安全地存储用户 token？从存储方式到使用流程说下思路。

**参考答案要点**：
- **存储**：用 **Keychain**，不用 UserDefaults（明文）。kSecAttrAccessible 选 **WhenUnlockedThisDeviceOnly**（仅本机、设备解锁可访问）或按需选可备份项。
- **读写**：封装成工具类（如 KeychainHelper），对外提供 saveToken、token、deleteToken；内部用 SecItemAdd / SecItemCopyMatching / SecItemDelete。
- **使用**：发请求前从 Keychain 取 token，放到 Header（如 Authorization）；网络层可在 requestSerializer 或统一拦截里自动加。
- **过期/401**：收到 401 或业务侧判断 token 失效时，删除 Keychain 中的 token，并跳转登录页。

详见 [实现原理与代码要点 - 1.5 场景](Phase3-实现原理与代码要点.md#15-场景怎么做)。

---

### 3.3 实现：数据库加列不丢数据

**题**：数据库表结构要新增一列，且不能丢老数据，你会怎么实现？

**参考答案要点**：
- 用 **版本号** 记录当前 DB 版本（如 SQLite 的 **PRAGMA user_version**，或自定义表存版本）。
- App 启动或首次使用 DB 时：读取当前 user_version；若**小于**目标版本（如 2），则执行**迁移**：用 **ALTER TABLE 表名 ADD COLUMN 列名 类型** 加列（若仅加列）；若需改类型或删列，则“备份旧表 → 建新表 → 拷贝数据 → 删旧表 → 重命名”。
- 迁移成功后执行 **PRAGMA user_version = 2** 更新版本。迁移前可备份 DB 文件或做好回滚方案。

详见 [实现原理与代码要点 - 2.3 场景](Phase3-实现原理与代码要点.md#23-场景怎么做)。

---

### 3.4 实现：所有请求自动带 token

**题**：网络层要支持“所有请求自动带上 token”，你会怎么实现？

**参考答案要点**：
- **方式一**：在 **AFHTTPSessionManager** 的 **requestSerializer** 上统一设置 Header：每次发请求前（或初始化时若 token 已存在）调用 `[requestSerializer setValue:token forHTTPHeaderField:@"Authorization"]`；token 变化时（登录/登出）再更新。
- **方式二**：封装层在构造 request 前，从 **Keychain** 取 token，通过 AF 的 **headers** 参数或自定义方法注入到当次请求的 Header。
- **方式三**：重写或 hook requestSerializer 的请求构造逻辑，在生成 NSURLRequest 时统一加上 Authorization。核心是“集中在一处加”，避免每个接口手写。

详见 [实现原理与代码要点 - 5.3 场景](Phase3-实现原理与代码要点.md#53-场景怎么做)。

---

## 四、代码关注题（代码里有什么坑）

### 4.1 block 与 self

**题**：在 AFNetworking 的 success block 里直接使用 self，会有什么问题？怎么避免？

**参考答案要点**：
- **问题**：可能**循环引用**。self 持有 manager（或持有发请求的 VC/对象），manager 持有 task，task 持有 block，block 里又捕获了 self，形成 self → … → block → self，导致 self 无法释放。
- **避免**：在进入 block 前 **__weak typeof(self) wself = self**，在 block 内用 **wself** 调用方法或属性；若 block 内需要“若 self 已释放则不执行”，可再判断 wself 是否为 nil。

详见 [实现原理与代码要点 - 3.3 代码关注点](Phase3-实现原理与代码要点.md#33-代码关注点)。

---

### 4.2 FMDB 多线程共享 FMDatabase

**题**：多线程里直接共享一个 FMDatabase 实例执行 SQL，可能有什么后果？

**参考答案要点**：
- **后果**：**sqlite3 连接不是线程安全的**，多线程同时用同一连接会导致崩溃、数据损坏或不可预期的错误。
- **正确做法**：使用 **FMDatabaseQueue**，所有操作通过 inDatabase 或 inTransaction 入队；或每个线程单独 open 一个 FMDatabase（不共享），但通常 Queue 更简单可靠。

详见 [实现原理与代码要点 - 2.1、2.2](Phase3-实现原理与代码要点.md#21-sqlite--fmdb-底层)。

---

### 4.3 NSUserDefaults 跨线程读写

**题**：在子线程里 setObject 然后主线程 objectForKey，一定能读到刚写的值吗？为什么？

**参考答案要点**：
- **不一定**。NSUserDefaults 有**内存缓存**，写盘是**异步**触发的；子线程 setObject 后，可能尚未写盘，主线程 objectForKey 可能仍读到旧值（或从缓存/磁盘读到未更新的内容）。
- **若需跨线程一致**：子线程写完后主动调用 **synchronize**（同步写盘），再在主线程读；或约定**统一在主线程**读写 UserDefaults，避免跨线程时序问题。

详见 [实现原理与代码要点 - 1.1](Phase3-实现原理与代码要点.md#11-nsuserdefaults-底层)。

---

## 小结

- **场景题**：从用户现象出发，联想到 Keychain 属性、事务、401 统一处理、resumeData 持久化等实现与设计。
- **实现原理题**：说清 synchronize、Keychain 更新、FMDatabaseQueue 串行、NSURLSession/AF 回调线程与解析流程。
- **设计/实现题**：断点续传、token 存储、DB 迁移、统一带 token 的完整思路与步骤。
- **代码关注题**：循环引用、FMDatabase 多线程、UserDefaults 跨线程等常见坑与避免方式。

配合 [Phase3-实现原理与代码要点](Phase3-实现原理与代码要点.md) 与 [Phase3-面试考点](Phase3-面试考点.md) 系统复习。
