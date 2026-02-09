# Day 35：HTTP/HTTPS 协议基础

## 概述

本单元学习 **HTTP/HTTPS** 协议要点（请求/响应、方法、状态码、Header），以及使用 **NSURLSession** 发起 GET/POST、读取状态码与 Body，为 Day36 AFNetworking 打基础。

## 知识点

### 1. HTTP 请求/响应结构

- **请求**：请求行（方法 + URL + 版本）+ 请求头 + 空行 + 可选的 Body。
- **响应**：状态行（版本 + 状态码 + 原因短语）+ 响应头 + 空行 + Body。

### 2. 常用方法与状态码

- **方法**：GET（取资源）、POST（提交数据）、PUT、DELETE 等。
- **状态码**：200 成功、201 创建、400 客户端错误、401 未授权、404 未找到、500 服务端错误等。

### 3. Header 常见字段

- 请求：Host、Content-Type、Content-Length、Authorization、User-Agent 等。
- 响应：Content-Type、Content-Length、Cache-Control 等。

### 4. HTTPS 与 TLS

- HTTPS = HTTP over TLS，加密传输；证书用于验证服务端身份。
- iOS 默认会校验证书；开发时注意 ATS（App Transport Security）配置，生产环境勿随意禁用校验。

### 5. NSURLSession

- 系统提供的网络 API，支持 data task、upload task、download task。
- 创建：`[NSURLSession sharedSession]` 或自定义 `NSURLSessionConfiguration`。
- 发起请求：创建 `NSURLRequest`（可设 URL、HTTPMethod、allHTTPHeaderFields、HTTPBody），再 `dataTaskWithRequest:completionHandler:`。

## 代码片段说明

- **GET/POST、读状态码与 Body**：见 `NetWork/Examples/Day35_HTTP/NSURLSessionDemo.m`。
- **HTTPS**：使用默认 NSURLSession 请求 https URL 即可；证书校验由系统完成，注释中说明 ATS 注意点。

## 注意事项 / 常见坑

- POST 时设置 `Content-Type`（如 application/x-www-form-urlencoded 或 application/json）和 HTTPBody。
- completionHandler 可能在子线程回调，更新 UI 需切回主线程。
- 生产环境不要关闭证书校验；Info.plist 中 ATS 例外仅用于必要场景。

## 小结

- HTTP 请求有方法、URL、Header、Body；响应有状态码、Header、Body。
- NSURLSession 是 iOS 网络基础，GET/POST 通过 NSURLRequest 配置，在 dataTask 的 completion 中处理 Data 与状态码。
- HTTPS 使用系统默认校验即可；理解 TLS 与证书有助于排查问题。

配套示例路径：`NetWork/Examples/Day35_HTTP/`。
