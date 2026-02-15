# 环境安装与基础配置

## Git 环境配置

### HTTPS 方式（推荐网络不稳定时使用）

解决 Git 连接 GitHub 的网络问题：

```bash
git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" && git config --global url."https://github.com/".insteadOf "git@github.com:"
```

如果上述命令不生效，可以尝试分别设置：

```bash
git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

### SSH 密钥配置（更安全稳定）

如果你希望使用 SSH 方式连接 GitHub，请按照以下步骤生成并配置 SSH 密钥（适用于 Windows、Linux 和 macOS）：

**1. 生成 SSH 密钥**

打开终端（Terminal、Git Bash 或 PowerShell），执行以下命令（将邮箱替换为你的 GitHub 注册邮箱）：

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

*   提示 `Enter file in which to save the key` 时，直接按回车（默认保存路径）。
*   提示 `Enter passphrase` 时，可以设置密码或直接按回车留空。

**2. 获取公钥内容**

执行以下命令查看生成的公钥内容：

```bash
# macOS / Linux
cat ~/.ssh/id_ed25519.pub

# Windows PowerShell
cat ~/.ssh/id_ed25519.pub
# 或者 Windows Command Prompt
type %userprofile%\.ssh\id_ed25519.pub
```

复制输出的所有内容（以 `ssh-ed25519` 开头）。

**3. 添加到 GitHub**

1.  登录 [GitHub](https://github.com/)。
2.  点击右上角头像 -> **Settings**。
3.  在左侧菜单中选择 **SSH and GPG keys**。
4.  点击 **New SSH key** 按钮。
5.  **Title**：随意填写（例如 "My Laptop"）。
6.  **Key**：粘贴刚才复制的公钥内容。
7.  点击 **Add SSH key** 保存。

**4. 验证连接**

在终端中执行：

```bash
ssh -T git@github.com
```

如果看到 `Hi <username>! You've successfully authenticated...`，说明配置成功。

## Node.js 环境安装 (NVM)

推荐使用 NVM (Node Version Manager) 来管理 Node.js 版本。

### 1. 下载并安装 NVM

在终端执行以下命令：

```bash
# 下载并安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

### 2. 激活 NVM

为了无需重启 shell 即可生效，执行：

```bash
# 代替重启 shell 的操作
\. "$HOME/.nvm/nvm.sh"
```

### 3. 安装 Node.js

下载并安装 Node.js v24：

```bash
# 下载并安装 Node.js
nvm install 24
```

### 4. 验证安装

验证 Node.js 和 npm 版本：

```bash
# 验证 Node.js 版本
node -v 
# 应该输出 "v24.x.x" (例如 v24.13.1)

# 验证 npm 版本
npm -v 
# 应该输出 "11.x.x" (例如 11.8.0)
```

## 扩展文件夹

如果 OpenClaw 没有扩展文件夹，请新建一个 `extensions` 文件夹，用于存放钉钉、企业微信、QQ 等插件。

## Mac 安装提示

Mac 用户安装时必须加入 `sudo` 提权命令。
