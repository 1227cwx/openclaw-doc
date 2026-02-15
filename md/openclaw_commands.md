# OpenClaw 常用命令

本文档汇总了 OpenClaw 的常用管理命令，方便随时查阅。

## 安装与更新

### 基础安装

```bash
# 清除缓存
npm cache clean --force

# 全局安装
npm i -g openclaw
```

### 更新版本

```bash
npm update -g openclaw
```

### 卸载

```bash
npm uninstall -g openclaw
```

## 故障修复

### 配置文件重置

如果遇到配置问题，可以使用修复命令：

```bash
openclaw doctor --fix
```

### 安装中断恢复

如果安装过程中断，可以使用以下命令重新打开配置向导：

```bash
openclaw onboard
```

## 日常使用命令

以下是 OpenClaw 运行和管理的常用命令：

### 网关管理

启动网关：

```bash
openclaw gateway start
```

重启网关：

```bash
openclaw gateway restart
```

停止网关：

```bash
openclaw gateway stop
```

### 交互与配置

命令行对话（TUI）：

```bash
openclaw tui
```

系统配置（修改模型、通道、网关等）：

```bash
openclaw config
```

### 维护

更新 OpenClaw 主程序：

```bash
npm update -g openclaw
```

卸载 OpenClaw：

```bash
npm uninstall -g openclaw
```

## 插件与扩展管理

### 添加扩展支持

如果下载完依赖后未显示插件，执行此命令：

```bash
openclaw channels add
```

### 启用插件

启用特定插件（例如飞书）：

```bash
openclaw plugins enable feishu
```

## 功能配置

### 搜索能力配置

配置 Web 搜索功能：

```bash
openclaw configure --section web
```

### 启动命令行对话

在终端中启动交互式对话界面：

```bash
openclaw tui
```

### 带详细日志启动

如果需要调试或查看详细运行信息，可以使用 `--verbose` 参数启动网关：

```bash
openclaw gateway --verbose
```
