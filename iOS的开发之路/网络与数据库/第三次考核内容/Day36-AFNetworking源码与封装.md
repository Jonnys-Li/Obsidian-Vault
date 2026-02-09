# Day 36：AFNetworking 源码理解与封装

## 概述

本单元理解 **AFNetworking** 的整体架构（基于 NSURLSession、AFHTTPSessionManager、序列化与安全），并实践**封装**：统一 BaseURL、通用 Header、超时、错误与状态码处理，以及 GET/POST 接口形式。

## 知识点

### 1. AFNetworking 整体架构

- 基于 NSURLSession，对 data/upload/download task 进行封装。
- **AFHTTPSessionManager**：最常用，负责发 HTTP 请求，支持 GET/POST 等，可配置 requestSerializer、responseSerializer、baseURL。
- **AFURLSessionManager**：更底层，管理 NSURLSession 与 task；AFHTTPSessionManager 在其之上增加 HTTP 便捷方法。
- **序列化**：AFJSONRequestSerializer / AFJSONResponseSerializer 等，负责请求体与响应体的序列化/反序列化。
- **安全**：AFSecurityPolicy 配置证书校验、允许自签名等（生产慎用）。

### 2. 核心类与调用链

- 创建 AFHTTPSessionManager → 设置 baseURL、requestSerializer、responseSerializer → 调用 `GET:parameters:headers:progress:success:failure:` 等。
- 内部会构造 NSURLRequest、创建 dataTask、在 completion 中调用 responseSerializer 解析，再回调 success/failure。

### 3. 封装原则

- **统一 BaseURL**：避免每个接口写完整 URL。
- **通用 Header**：如 Token、AppVersion、Content-Type 在 manager 或 requestSerializer 中统一设置。
- **超时**：通过 NSURLSessionConfiguration 或 requestSerializer 的 timeout 设置。
- **错误与状态码**：在 failure 或 success 中根据 HTTP 状态码（如 401、500）做统一提示或登出等；可封装一层，把非 2xx 转为 NSError 走失败回调。
- **回调形式**：block（success/failure）最常用；也可用 delegate 或 RAC 等。

## 代码片段说明

- **AFNetworkingManager**：见 `NetWork/Examples/Day36_AFNetworking/AFNetworkingManager.h/.m`，单例、BaseURL、通用 Header、GET/POST、统一错误处理。
- **调用示例**：见同目录下 `AFNetworkingManagerUsage.m` 或文档内说明。

## 注意事项 / 常见坑

- baseURL 末尾是否带 `/` 与 path 是否以 `/` 开头会影响最终 URL，需统一约定。
- success block 中若做 UI 操作，确认是否已在主线程（AFNetworking 默认回调到主线程）。
- 取消请求：保存 NSURLSessionDataTask，在适当时机 cancel。

## 小结

- AFNetworking 是 NSURLSession 的上层封装，AFHTTPSessionManager 是日常使用入口。
- 封装时统一 BaseURL、Header、超时与错误/状态码处理，便于业务层只关心参数与回调。
- 配套示例提供可直接复用的 Manager 与调用示例。

配套示例路径：`NetWork/Examples/Day36_AFNetworking/`。
