
1. 用法![[截屏2026-02-05 09.57.08.png]]

| **参数名**     | 类型             | 说明                                                 |
| ----------- | -------------- | -------------------------------------------------- |
| GET         | NSString *     | 接口的 **URL 地址**（例如：`https://api.example.com/data`）。 |
| parameters  | id             | 传给服务器的 **键值对参数**（通常是 `NSDictionary`）。              |
| headers     | NSDictionary * | **请求头**（如 Token、User-Agent 等），没有可传 `nil`。          |
| progress    | Block          | **进度回调**，下载大文件时有用，一般传 `nil`。                       |
| success     | Block          | **请求成功**后的回调，`responseObject` 是服务器返回的数据。           |
| **failure** | Block          | **请求失败**后的回调，通过 `error` 查看错误原因。                    |
