# 高级部署

## 向量记忆库服务部署

向量记忆库（AIVectorMemory）跨会话持久化记忆 MCP Server。

### 安装步骤

1. **确保有 python3 环境**

2. **安装依赖**

```bash
pip install aivectormemory
```

3. **在 root 目录中新建一个文件夹**（随便什么名字都行）

```bash
mkdir -p /root/name
cd /root/namen
```

4. **上传脚本文件**

下载 <a href="/start.py" download="start.py">start.py</a> 脚本文件到该目录

5. **运行向量记忆库服务**

```bash
python3 start.py
```

6. **安装 skills 到大龙虾**

下载 <a href="/aivectormemory-api.tar.gz" download="aivectormemory-api.tar.gz">aivectormemory-api.tar.gz</a> 压缩包，然后安装：

```bash
解压到大龙虾的/root/.openclaw/workspace/skills目录中
```

7. **配置大龙虾**

与大龙虾对话，让他把下面的提示词写进他的 AGENTS.md：

```
你现在可以使用向量记忆库来存储和检索长期记忆。记忆库通过 tags 隔离不同 agent 的记忆。

使用方法：
- remember: 存储记忆到向量库
- recall: 从向量库检索相关记忆
- forget: 删除指定的记忆
- status: 查看记忆库状态
- track: 追踪任务进度
- task: 任务管理
- auto_save: 自动保存重要信息

每次调用时必须带上 agent_tag 参数作为你的个人标识。
```

然后继续跟他说，让他把关于调用 MEMORY.md 长期记忆调用相关的方法全部删掉，改成使用记忆库，使用方法对照 skills。

### 进程守护配置

编辑服务文件：`vim /etc/systemd/system/aivectormemory.service`

```ini
[Unit]
Description=AIVectorMemory HTTP API Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/aivectormemory
ExecStart=/usr/bin/python3 /opt/aivectormemory/start.py
Restart=always
RestartSec=5
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
```

**管理命令：**

```bash
# 重载配置
systemctl daemon-reload

# 启动服务
systemctl start aivectormemory

# 开机自启
systemctl enable aivectormemory

# 查看状态
systemctl status aivectormemory

# 查看日志
journalctl -u aivectormemory -f
```

### API 端点

向量记忆库服务默认运行在 `http://0.0.0.0:9081`

**健康检查：**

```bash
curl http://localhost:9081/health
```

**主要功能：**

- `POST /remember` - 存储记忆
- `POST /recall` - 检索记忆
- `POST /forget` - 删除记忆
- `POST /status` - 查看状态
- `POST /track` - 追踪任务
- `POST /task` - 任务管理
- `POST /auto_save` - 自动保存

**请求示例：**

```bash
# 存储记忆
curl -X POST http://localhost:9081/remember \
  -H "Content-Type: application/json" \
  -d '{
    "agent_tag": "agent:mybot",
    "content": "这是一条重要的记忆",
    "tags": ["important", "user_info"]
  }'

# 检索记忆
curl -X POST http://localhost:9081/recall \
  -H "Content-Type: application/json" \
  -d '{
    "agent_tag": "agent:mybot",
    "query": "重要记忆",
    "tags": ["important"]
  }'
```

### 配置说明

向量记忆库服务使用以下配置：

- **项目目录**: `/root/.aivectormemory`
- **API 端口**: `9081`
- **多 agent 隔离**: 通过 `agent_tag` 参数实现

每个 agent 的记忆会自动添加对应的 tag，确保不同 agent 之间的记忆隔离。
