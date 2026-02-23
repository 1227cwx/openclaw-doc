# 📱 远程控制安卓手机

> 🎯 通过 OpenClaw 远程控制您的安卓手机，实现自动化操作。

---

### ⚠️ 前提条件

| 项目 | 要求 |
|------|------|
| 📲 安卓系统版本 | 必须大于 **Android 11** |

---

## 🔧 一、使用 Tailscale 构建 VPN 隧道

> 💡 Tailscale 是一款零配置 VPN 工具，可以帮助您的服务器 OpenClaw 和本地手机建立安全的虚拟局域网连接。

### 📥 步骤 1：在服务器上安装 ADB 工具和 Tailscale

```
🗣️ 与您的 OpenClaw 对话，让她安装 adb 工具和 Tailscale 虚拟局域网工具。
```

<p align="center">
  <img src="/android-3.jpg" width="400" />
</p>
<p align="center"><i>📷 图1: 安装 ADB 工具和 Tailscale</i></p>

---

### 📱 步骤 2：在安卓手机上安装并登录 Tailscale

```
📲 在您的安卓手机上下载并安装 Tailscale 应用，然后登录您的 Tailscale 账号。
```

---

### 🌐 步骤 3：服务器 OpenClaw 登录 Tailscale

```
🗣️ 与服务器上的 OpenClaw 对话，让她进行 Tailscale 登录。
🔗 她会回复您一个登录链接。点击该链接完成登录。
```

> ✅ 完成以上步骤后，您的服务器 OpenClaw 和本地手机将通过 Tailscale 构建的 VPN 隧道处于同一虚拟局域网中。

---

## 🔗 二、配置无线调试并与 OpenClaw 配对

### ⚙️ 步骤 1：打开手机开发者设置

```
📲 在安卓手机上，进入「设置」→「关于手机」
👆 连续点击「版本号」多次，直到开启开发者模式
🔙 然后返回「设置」→「系统」→「开发者选项」
```

---

### 📡 步骤 2：启用无线调试

```
🔍 在开发者选项中找到并打开「无线调试」
```

<p align="center">
  <img src="/android-2.jpg" width="400" />
</p>
<p align="center"><i>📷 图2: 启用无线调试</i></p>

---

### 🔑 步骤 3：获取配对信息

```
👆 点击「无线调试」下的「使用配对码配对设备」
👀 您会看到一个配对码、IP 地址和端口
```

<p align="center">
  <img src="/android-3.jpg" width="400" />
</p>
<p align="center"><i>📷 图3: 获取配对信息</i></p>

---

### 💬 步骤 4：告知 OpenClaw 配对信息

```
📤 将配对码、IP 地址和端口告诉您的 OpenClaw
   例如：192.168.1.100:37489

⚠️ 注意：无线调试页面在设备名称下方还有一个连接 IP 地址和端口
   例如：192.168.1.100:5555
   这个也要一并告诉 OpenClaw，并明确说明这是「连接 IP 和端口」
```

> ⚠️ **重要提示**：配对地址和连接地址是不同的，务必向 OpenClaw 明确说明！

> ✅ 如果操作无误，OpenClaw 会回复您配对成功。至此，您就可以让 OpenClaw 控制您的安卓手机了！

<p align="center">
  <img src="/android-4.jpg" width="400" />
</p>
<p align="center"><i>📷 图4: 配对成功</i></p>

---

## 🚀 三、高级玩法：使用 SSH 隧道连接（可选）

> 💡 如果您觉得 Tailscale 连接速度慢或不稳定，可以尝试通过 SSH 隧道建立连接。

### 📋 前提条件

```
✅ 一台电脑（Windows/macOS/Linux）
✅ 安卓手机和电脑处于同一局域网中
```

---

### 📲 步骤 1：在安卓手机上开启无线调试并进入配对模式

```
📱 确保手机的无线调试已打开
👆 停留在「使用配对码配对设备」界面
```

---

### 💻 步骤 2：在电脑上建立 SSH 隧道

```
🖥️ 打开电脑的命令行工具（如 CMD 或 PowerShell）
📤 执行以下两条命令，将手机的连接端口和配对端口分别转发到服务器上
⚠️ 请将示例中的 IP 地址和端口替换为您的实际信息
```

#### 🔹 隧道 1（连接端口）：

```bash
ssh -fN -R 5555:你的手机ip地址:连接端口 -o ServerAliveInterval=30 -o ServerAliveCountMax=10 root@大龙虾服务器IP

# 📝 示例：
# ssh -fN -R 5555:192.168.1.100:5555 -o ServerAliveInterval=30 -o ServerAliveCountMax=10 root@65.78.45.15
```

#### 🔹 隧道 2（配对端口）：

```bash
ssh -fN -R 5556:你的手机ip地址:配对端口 -o ServerAliveInterval=30 -o ServerAliveCountMax=10 root@大龙虾服务器IP

# 📝 示例：
# ssh -fN -R 5556:192.168.1.100:37489 -o ServerAliveInterval=30 -o ServerAliveCountMax=10 root@65.78.45.15
```

---

### 📢 步骤 3：告知 OpenClaw 隧道信息

```
📤 将以上两条命令告知您的 OpenClaw
🔢 告知手机上显示的配对端口（例如：37489）
🔢 告知连接端口（例如：5555）
🤖 她会自行进行配对
```

> 🎉 至此，服务器 OpenClaw 远程控制本地安卓手机的连接已成功建立。您可以开始向她发号施令了！

<p align="center">
  <img src="/android-5.jpg" width="400" />
</p>
<p align="center"><i>📷 图5: 连接成功</i></p>
