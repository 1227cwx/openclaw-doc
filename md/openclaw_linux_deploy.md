# Linux 服务部署

## Linux 虚拟机 / 云服务器（Debian/Ubuntu）

1.  先安装 Node.js 和 Git
2.  安装 OpenClaw：`npm i -g openclaw`
3.  初始化配置：`openclaw onboard`

## 进程守护配置 (Systemd)

### OpenClaw Gateway 服务

编辑服务文件：`vim /etc/systemd/system/openclaw-gateway.service`

```ini
[Unit]
Description=OpenClaw Gateway Service
After=network.target dbus.target

[Service]
User=root
Type=simple
# 核心修改：使用找到的openclaw绝对路径
ExecStart=/root/.nvm/versions/node/v22.22.0/bin/openclaw gateway
# 可选：如果有stop子命令，路径也要对应
ExecStop=/root/.nvm/versions/node/v22.22.0/bin/openclaw gateway stop
# 补充nvm/node环境变量（避免服务启动时找不到Node）
Environment="NODE_HOME=/root/.nvm/versions/node/v22.22.0"
Environment="PATH=/root/.nvm/versions/node/v22.22.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# 异常重启配置
Restart=always
RestartSec=5
# 日志输出（便于排查）
StandardOutput=journal+console
StandardError=journal+console
# 工作目录（可选，确保openclaw有读写权限）
WorkingDirectory=/root

[Install]
WantedBy=multi-user.target
```

**配置说明：**

*   `ExecStart`: 修改为 `openclaw` 的绝对路径。
*   `ExecStop`: 修改为 `openclaw` 的绝对路径。
*   `Environment="NODE_HOME=..."`: 修改为 Node.js 的安装目录。
*   `Environment="PATH=..."`: 修改为包含 Node.js bin 目录的路径。

**管理命令：**

```bash
# 重载配置
systemctl daemon-reload
# 启动服务
systemctl start openclaw-gateway
# 开机自启
systemctl enable openclaw-gateway
# 查看状态
systemctl status openclaw-gateway
```
 

## OpenClaw 内部浏览器配置

> 注意：必须先安装 Chromium

### 安装 Playwright

全局安装 Playwright（必须）：

```bash
npm install -g playwright
```

### 安装浏览器

```bash
# 1. 清除之前的镜像设置，重新指定 npmmirror 源
set PLAYWRIGHT_DOWNLOAD_HOST=https://npmmirror.com/mirrors/playwright/

# 2. 重新安装 1.40.0 对应的浏览器
playwright install
```

### Chrome Headless 启动参数

OpenClaw 使用以下参数启动 Chrome Headless：

```bash
/usr/bin/google-chrome \
# 路径可能会根据系统不同而不同
--headless=new \
--remote-debugging-port=18800 \
--remote-debugging-address=127.0.0.1 \
--no-sandbox \
--user-data-dir=/tmp/chrome-cdp \
--no-first-run \
--disable-gpu
```

### 进程守护开启自启

编辑服务文件：`vim /etc/systemd/system/chrome-headless.service`

```ini
[Unit]
Description=Chrome Headless Service for OpenClaw  # 服务描述
After=network.target  # 网络启动后再启动该服务

[Service]
Type=simple
User=root  # 以root用户运行（和你手动操作的用户一致）
Group=root
WorkingDirectory=/tmp
# 启动命令（和你手动启动的参数完全一致）
ExecStart=/usr/bin/google-chrome --headless=new --remote-debugging-port=18800 --remote-debugging-address=127.0.0.1 --no-sandbox --user-data-dir=/tmp/chrome-cdp --no-first-run --disable-gpu
# 进程崩溃时自动重启
Restart=always
RestartSec=5  # 崩溃后5秒重启
# 日志输出配置
StandardOutput=append:/var/log/chrome-headless.log
StandardError=append:/var/log/chrome-headless.log

[Install]
WantedBy=multi-user.target  # 多用户模式下开机自启
```

**管理命令：**

```bash
# 2. 重新加载systemd配置（识别新创建的服务）
systemctl daemon-reload

# 3. 启动服务（立即后台运行）
systemctl start chrome-headless

# 4. 设置开机自启（重启系统后自动启动）
systemctl enable chrome-headless

# 5. 验证服务状态（关键：看Active是否为active (running)）
systemctl status chrome-headless
```

### 配置文件修改

修改 `openclaw.json` 配置文件，在文件末尾（倒数第二个花括号后）添加以下浏览器配置：

```json
  ,"browser": {
    "enabled": true, 
    "cdpUrl": "http://127.0.0.1:18800", 
    "remoteCdpTimeoutMs": 3000, 
    "remoteCdpHandshakeTimeoutMs": 6000, 
    "defaultProfile": "chrome",
    "color": "#FF4500",
    "headless": false,//是否以无头模式运行
    //Windows等有桌面环境时可设为false每次会打开浏览器窗口。
    // 如果在服务器上运行或者不想看到浏览器窗口设为true
    "noSandbox": false,
    "attachOnly": false,
    "executablePath": "你的浏览器可执行文件路径",
    //使用openclaw browser --browser-profile openclaw status获取
    "profiles": {
      "openclaw": { "cdpPort": 18800, "color": "#FF4500" },
      "work": { "cdpPort": 18801, "color": "#0066CC" },
      "remote": { "cdpUrl": "http://10.0.0.42:9222", "color": "#00AA00" }
    }
  }
```
