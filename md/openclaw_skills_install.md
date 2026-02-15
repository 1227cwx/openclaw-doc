# Skills 安装

OpenClaw 支持通过技能扩展功能，以下是技能的安装方法。

## 平台一：clawhub.ai

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

## 平台二：skills.sh

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
 
