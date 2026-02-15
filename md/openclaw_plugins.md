# 插件与扩展

## 飞书插件

OpenClaw 官方自带飞书插件，但默认不启用。

启用命令：

```bash
openclaw plugins enable feishu
```

## QQ 机器人

安装 QQ 机器人插件：

```bash
rmdir /s /q qqbot
git clone https://github.com/sliverp/qqbot.git && openclaw plugins install ./qqbot
```

## Skills 技能包

### 平台一：clawhub.ai

访问 [clawhub.ai](https://clawhub.ai) 获取更多技能。

**安装命令：**

优先使用命令 1，如果无法使用则尝试命令 2。

**命令 1：**

```bash
clawhub install [技能包名]
# 示例
clawhub install openbroker
```

**命令 2：**

```bash
npx clawhub@latest install [技能包名]
# 示例
npx clawhub@latest install openbroker
```

### 平台二：skills.sh

访问 [skills.sh](https://skills.sh) 获取更多技能。

CLI 可以直接使用 `npx` 运行，无需安装：

```bash
npx skills add <skill-name>
```

**基本用法：**

通过指定所有者和技能名称来安装技能：

```bash
npx skills add vercel-labs/agent-skills
```

这将下载技能并将其配置以与您的 AI 代理一起使用。

**推荐安装的 Skills：**

*   `proactive-agent-t-1-2-4`：【主动代理】
*   `find-skills`：【查找技能】
*   `self-reflection`：【自我反思】
*   `reflect-learn`：【自我提升】
*   `baidu-search`：【百度搜索】

## Telegram 配对

Telegram 配对命令示例：

```bash
openclaw pairing approve telegram 配对码
```

## Windows 浏览器扩展

### 安装步骤

1.  **位置**: `C:\openclaw-browser-extension\`
2.  **功能**: 允许通过 Chrome 控制浏览器
3.  **安装**:
    *   打开 Chrome 扩展管理页面 `chrome://extensions/`
    *   启用 "开发者模式"
    *   点击 "加载解压缩的扩展程序"
    *   选择文件夹 `C:\openclaw-browser_EXTENSION`

### 激活连接

*   点击扩展的 "固定" 按钮加入工具栏
*   在任意网页上点击 OpenClaw 扩展图标
*   应该显示 "已连接" 状态

## Windows 批处理启动脚本

创建一个名为 `start_openclaw.bat` 的文件，填入以下内容：

```batch
@echo off
title OpenClaw Gateway
chcp 65001 >nul & echo 正在启动 OpenClaw...
openclaw gateway
pause
```

保存后双击该文件即可启动。
