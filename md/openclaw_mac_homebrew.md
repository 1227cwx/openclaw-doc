# Mac Homebrew 安装

Homebrew 是 Mac 上最常用的包管理器，安装/升级/卸载 Node 更方便。

## 安装 Homebrew

终端执行官方安装命令：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 通过 Homebrew 安装 Node

```bash
brew install node
```

## 验证与管理

验证安装：

```bash
node -v
```

升级 Node：

```bash
brew upgrade node
```

卸载 Node：

```bash
brew uninstall node
```
