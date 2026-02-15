# 中转 API 配置

配置 OpenClaw 使用中转 API 服务（如 zhongzhuan.chat）。

## 配置文件示例

以下是 `zhongzhuan` 部分的配置示例：

```json
    "zhongzhuan": {
      "baseUrl": "https://api.zhongzhuan.chat/v1",
      "apiKey": "你的中转 API 密钥",
      "api": "openai-completions",// 中转 API 协议。默认值为 openai-completions。
      "models": [
        {
          "id": "中转模型名称",
          "name": "中转模型名称",
          "reasoning": false,// 是否支持推理(深度思考模式)。默认值为 false。
          "input": [
            "text",// 支持文本输入
            "image",// 支持图片输入(根据中转站提供的模型来判断是否支持)
            "xxxx"// 其他输入类型
          ],
          "cost": {
            "input": 0,// 输入成本(单位：根据中转 API 文档来定)
            "output": 0,// 输出成本(单位：根据中转 API 文档来定)
            "cacheRead": 0,// 缓存读取成本(单位：根据中转 API 文档来定)
            "cacheWrite": 0// 缓存写入成本(单位：根据中转 API 文档来定)
          },
          "contextWindow": 200000,
          // 上下文窗口tokens数(这个数值决定了 AI 一次性能读多少内容)
          "maxTokens": 4096,
          // 单次最大输出tokens数(这个数值限制了 AI 每次回答最长能写多少)
        }
      ]
    }
```
