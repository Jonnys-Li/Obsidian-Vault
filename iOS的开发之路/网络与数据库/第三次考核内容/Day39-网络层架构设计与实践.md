# Day 39：网络层架构设计与实践

## 概述

本单元学习**网络层分层思路**（API 层、业务层、数据层）、**请求封装**（URL、参数、Method）、**响应统一格式**与错误码处理，以及**可扩展性**（新接口、多环境），并结合 AFNetworking 实现简单网络层。

## 知识点

### 1. 分层思路

- **API 层**：定义接口路径、参数、Method，可集中在一个 APIConfig 或按模块拆分。
- **业务层**：调用 API 层发起请求，解析响应，转成业务模型或回调业务数据。
- **数据层**：实际发请求的组件（如封装的 AFNetworkingManager），负责 BaseURL、Header、超时、错误转换。

### 2. 请求封装

- **URL**：BaseURL + path，或按环境切换 BaseURL。
- **参数**：GET 用 query，POST 用 body（JSON 或 form）。
- **Method**：GET/POST/PUT/DELETE 等，在配置或请求对象中声明。

### 3. 响应统一格式与错误

- 常见约定：`{ "code": 0, "message": "ok", "data": { ... } }`，code 非 0 表示业务错误。
- 网络层可解析 code，非 0 时构造 NSError 或业务错误对象，走失败回调；同时处理 HTTP 状态码（401 登出、500 提示等）。
- 成功时只把 data 或整个 response 交给业务层。

### 4. 可扩展性

- **新接口**：新增 API 路径与参数即可，网络层保持统一入口。
- **多环境**：BaseURL 按 Debug/Release 或配置切换；可抽象 Environment 枚举或配置类。
- **与 AFNetworking 配合**：封装类内部使用 AFHTTPSessionManager，对外提供简洁的 request(path, params, success, failure) 或按业务划分的 login、fetchList 等方法。

## 代码片段说明

- **NetworkManager + APIConfig**：见 `NetWork/Examples/Day39_NetworkArch/NetworkManager.h/.m`、`APIConfig.h`，统一发起请求、解析 JSON、成功/失败回调。
- **示例 API 调用**：登录、列表等 2～3 个示例，见 `APIConfig` 与调用示例类。

## 注意事项 / 常见坑

- 统一错误格式，避免业务层到处判断 HTTP 状态码与 body。
- 回调线程：明确是否回到主线程，避免 UI 在子线程更新。
- 请求取消：保存 task，在页面消失或新请求前 cancel。

## 小结

- 网络层分层便于维护与扩展；请求封装与响应/错误统一能减少重复代码。
- 配套示例提供 NetworkManager + APIConfig 及多个 API 调用示例，可直接扩展为项目网络层。

配套示例路径：`NetWork/Examples/Day39_NetworkArch/`。
