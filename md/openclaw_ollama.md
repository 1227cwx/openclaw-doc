# 接入本地大模型 (Ollama)

OpenClaw 支持通过 Ollama 接入本地大模型。

## 快速设置

使用以下命令快速启动配置：

```bash
ollama launch openclaw
```

> 之前称为 `Clawdbot`。`ollama launch clawdbot` 仍然可以作为别名使用。

这将配置 OpenClaw 使用 Ollama 并启动网关。如果网关已经运行，无需进行任何更改，因为网关将自动重新加载更改。

## 配置而不启动

如果你只想进行配置而不启动网关，可以使用 `--config` 参数：

```bash
ollama launch openclaw --config
```

## 英伟达显卡设置

参考链接：[设置Ollama模型跑在GPU上-哔哩哔哩](https://b23.tv/4rPacTQ)

### 系统环境变量

为了确保 Ollama 使用 CUDA，请添加以下系统环境变量(Windows)：

```bash
  OLLAMA_CUDA: 1
```
