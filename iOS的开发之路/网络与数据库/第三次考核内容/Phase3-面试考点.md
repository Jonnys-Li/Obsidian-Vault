# 第3阶段：面试考点

本文档按模块整理**数据持久化与网络编程**的高频考点，采用问答形式并给出简洁参考答案，便于考前背诵与面试准备。系统概念见 [Phase3-基础知识](Phase3-基础知识.md)。

---

## 1. 本地存储

**Q1：沙盒是什么？Documents 和 Caches 的区别？是否备份？**

- **沙盒**：iOS 为每个应用分配的独立文件系统区域，应用只能访问自己沙盒内的文件，无法直接访问其他应用或系统目录。
- **Documents**：存放用户生成、需长期保存的内容（如用户文档、导出文件），**会参与 iCloud/ iTunes 备份**。
- **Caches**：存放可重新下载的缓存（如图片、接口缓存），**不备份**；系统在存储紧张时可能清理。
- **tmp**：临时文件，**不备份**，系统可能随时清理。

**Q2：NSUserDefaults 适用场景与限制？能存什么类型？**

- **适用场景**：轻量配置（主题、开关、上次选项等），键值对、读写简单。
- **限制**：不宜存大量数据；主线程同步读写；同一 App Group 内可共享。
- **能存类型**：plist 兼容类型——NSString、NSNumber、NSData、NSDate、NSArray、NSDictionary；自定义对象需转成上述类型或归档为 Data。

**Q3：Keychain 用来存什么？和 UserDefaults 的区别？**

- **Keychain**：用来存**敏感信息**（密码、token、证书等），系统级加密；卸载应用后仍可保留（可选），同一开发者账号下新安装的 App 可读取。
- **区别**：UserDefaults 存普通配置、plist 明文存储；Keychain 存敏感数据、加密存储、可跨应用（同开发者）共享。存 token/密码应用 Keychain，存主题/开关用 UserDefaults。

**Q4：如何选择用 UserDefaults、Keychain 还是文件存储？**

- **UserDefaults**：用户设置、开关、简单配置，数据量小、非敏感。
- **Keychain**：密码、token、证书等敏感信息。
- **文件存储**：用户文档、导出文件用 **Documents**；可重新下载的缓存用 **Caches**；临时中间结果用 **tmp**。选型时考虑是否敏感、是否需备份、数据量大小。

---

## 2. 数据库

**Q5：SQLite 的特点？FMDB 是什么？**

- **SQLite**：轻量级、无独立服务器、**文件型**数据库，内置于 iOS；数据存于单一文件，通过路径打开。
- **FMDB**：Objective-C 对 SQLite 的封装库，提供 FMDatabase（单库操作）、FMDatabaseQueue（多线程安全）、FMResultSet（结果集）等，API 更易用。

**Q6：FMDatabase 和 FMDatabaseQueue 区别？多线程如何保证安全？**

- **FMDatabase**：对应一个数据库文件，直接执行 SQL；**同一实例不宜在多线程间共享**，否则可能崩溃或数据异常。
- **FMDatabaseQueue**：用串行队列包装数据库操作，**多线程安全**。所有访问通过 `inDatabase:` 或 `inTransaction:` 的 block 入队，由 FMDB 串行执行，保证同一时刻只有一个线程操作 db。
- **多线程安全做法**：使用 FMDatabaseQueue，在 block 内拿到 FMDatabase 执行 SQL，不要在多线程共享同一个 FMDatabase。

**Q7：什么是事务？什么时候用？**

- **事务**：把多条 SQL 当作一个**原子操作**：要么全部成功（commit），要么全部回滚（rollback），保证一致性。
- **何时用**：大批量插入/更新、多步操作必须同时成功或同时失败时。例如批量插入 1000 条，用事务可显著提升性能并保证要么全写入要么全不写。FMDB 中 `beginTransaction` → 执行多条语句 → `commit` 或 `rollback`，或使用 `inTransaction:` block。

**Q8：数据库迁移一般怎么做？（版本号、加列、重建表）**

- **版本号**：用 SQLite 的 `PRAGMA user_version` 或自定义表记录当前 DB 版本；App 启动时读取版本，按版本执行对应迁移。
- **加列**：SQLite 支持 `ALTER TABLE 表名 ADD COLUMN 列名 类型`，适合简单加字段。
- **改类型、删列**：SQLite 的 ALTER 不支持，需**重建表**：备份旧表 → 建新表（新结构）→ 拷贝数据 → 删旧表 → 重命名新表（或替换）。复杂迁移务必在测试环境验证后再发布。

---

## 3. HTTP/HTTPS 与网络

**Q9：HTTP 常见方法、状态码？GET 和 POST 区别？**

- **常见方法**：GET（取资源）、POST（提交数据）、PUT、DELETE 等。
- **常见状态码**：200 成功、201 创建、400 客户端错误、401 未授权、404 未找到、500 服务端错误。
- **GET 与 POST**：GET 参数在 URL 的 query 中，幂等、可缓存、长度受 URL 限制；POST 参数通常在 body 中，用于提交数据、不幂等、一般不被缓存。语义上 GET 取资源、POST 提交/创建资源。

**Q10：HTTPS 和 HTTP 的区别？证书校验做什么？**

- **区别**：HTTPS = HTTP over TLS，在 HTTP 之下增加加密与完整性校验，防止窃听与篡改；HTTP 明文传输。
- **证书校验**：用于验证**服务端身份**，防止中间人伪造服务器。客户端用系统或内置的 CA 校验证书链，确认域名与证书一致、未过期、未被吊销。iOS 默认会校验证书，生产环境不要关闭校验。

**Q11：NSURLSession 和 NSURLConnection 的关系？（简述）**

- **NSURLConnection**：iOS 7 之前使用的网络 API，已不推荐。
- **NSURLSession**：iOS 7 引入，是当前推荐方式；支持 data/upload/download task、可配置 NSURLSessionConfiguration、支持后台下载等。可理解为 NSURLConnection 的替代与增强。

**Q12：断点续传原理？resumeData 怎么用？**

- **原理**：HTTP 支持 **Range 请求**（请求头 `Range: bytes=start-end`），服务端返回 206 与对应片段；客户端把已下载部分与本次片段拼接。若服务端不支持 Range，则无法断点续传。
- **resumeData**：使用 NSURLSessionDownloadTask 时，通过 `cancelByProducingResumeData:` 取消可得到 **resumeData**（系统生成的恢复数据）。再次创建任务时用 `downloadTaskWithResumeData:` 传入该 Data，即可从断点继续。需将 resumeData **持久化**（如写入 Caches），App 重启后才能恢复；resumeData 有时效性与系统版本依赖。

---

## 4. AFNetworking 与封装

**Q13：AFNetworking 大致架构？和 NSURLSession 的关系？**

- **关系**：AFNetworking 是 **NSURLSession 的上层封装**，内部使用 NSURLSession 发请求。
- **架构**：AFURLSessionManager 管理 NSURLSession 与 task；AFHTTPSessionManager 在其之上提供 HTTP 便捷方法（GET/POST 等），并配置 requestSerializer、responseSerializer（如 JSON 序列化）；还有 AFSecurityPolicy 负责证书校验等。日常开发主要用 AFHTTPSessionManager。

**Q14：网络层为什么要封装？一般封装哪些内容（BaseURL、Header、错误处理等）？**

- **为什么要封装**：避免每个接口重复写 URL、Header、解析逻辑；统一处理错误与状态码；便于切换环境、维护与扩展。
- **一般封装**：**BaseURL** 统一，path 按接口配置；**通用 Header**（Token、AppVersion、Content-Type 等）；**超时**配置；**错误与状态码**统一处理（如非 2xx 转 NSError、401 登出）；**回调**统一为 success/failure block。业务层只关心 path、参数与回调，不关心底层 URL 拼接与错误解析细节。

---

## 5. 网络数据处理与架构

**Q15：文件上传用哪种 Content-Type？multipart 是什么？**

- **Content-Type**：上传文件常用 **multipart/form-data**，用于表单中包含文件字段。
- **multipart**：用 boundary 字符串把请求 body 分成多段，每段可对应一个表单字段或一个文件块；服务端根据 boundary 解析出字段和文件。NSURLSession 需手动拼接，AFNetworking 的 `constructingBodyWithBlock` 中可用 `appendPartWithFileURL` 等方便拼接。

**Q16：JSON 解析用哪个 API？字典转模型有什么方式？**

- **API**：系统 **NSJSONSerialization**：`JSONObjectWithData:options:error:` 将 NSData 解析为 NSDictionary 或 NSArray；`dataWithJSONObject:options:error:` 将对象序列化为 JSON Data。
- **字典转模型**：手写 `initWithDictionary:` 或 `modelWithDictionary:`，按 key 取值并做 null 判断；或使用 **MJExtension**、**YYModel** 等库自动映射。注意类型与 nil 判断，避免崩溃。

**Q17：网络层分层怎么分？API 层、业务层、数据层各做什么？**

- **API 层**：定义接口 path、参数、Method（GET/POST 等），可集中在 APIConfig 或按模块拆分；不关心具体请求实现。
- **业务层**：调用 API 层发起请求，解析响应（如 JSON → 模型），把结果回调给 UI 或上层；处理业务逻辑与错误提示。
- **数据层**：实际发请求的组件（如封装的 AFNetworkingManager），负责 BaseURL、Header、超时、与 AFNetworking/NSURLSession 对接、统一错误转换；对业务层暴露简洁的 request(path, params, success, failure) 或按业务划分的 login、fetchList 等方法。

---

## 小结

- 本地存储：沙盒、Documents/Caches/tmp、NSUserDefaults、Keychain 的用途与选型。
- 数据库：SQLite、FMDB、FMDatabaseQueue、事务、迁移。
- HTTP/HTTPS：方法、状态码、GET/POST、证书；NSURLSession、断点续传与 resumeData。
- AFNetworking：与 NSURLSession 关系、封装目的与内容。
- 网络数据处理：multipart 上传、JSON 解析与模型转换、网络层分层。

配合 [Phase3-基础知识](Phase3-基础知识.md) 与 [Day40-第3阶段考核](Day40-第3阶段考核.md) 系统复习与自测。
