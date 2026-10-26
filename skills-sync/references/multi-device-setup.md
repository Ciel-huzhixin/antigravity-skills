# 跨设备统一 Antigravity 技能接入指南

本指南用于在任意新电脑（Windows、macOS 或 Linux）上快速挂载并同步本技能仓库。

---

## 快速接入步骤

### 第一步：克隆仓库到用户主目录
在终端中执行以下命令（建议统一放在用户主目录下）：

```bash
git clone https://github.com/Ciel-huzhixin/antigravity-skills.git ~/antigravity-skills
```

> **Windows PowerShell 用户注意**：
> `~/antigravity-skills` 等价于 `$HOME\antigravity-skills`（例如 `C:\Users\<用户名>\antigravity-skills`）。

---

### 第二步：配置全局技能清单 (`skills.json`)

Antigravity 会自动读取 `~/.gemini/config/skills.json`。在该文件中声明本仓库路径，Antigravity 即可自动发现仓库下的所有技能。

#### 方法 A：使用本仓库内置初始化命令（推荐）

- **Windows (PowerShell)**:
  ```powershell
  & "$HOME\antigravity-skills\skills-sync\scripts\sync-skills.ps1" -Action init
  ```

- **macOS / Linux**:
  ```bash
  bash ~/antigravity-skills/skills-sync/scripts/sync-skills.sh init
  ```

#### 方法 B：手动创建或修改配置文件
若配置文件已存在其他项，请在 `~/.gemini/config/skills.json` 的 `entries` 数组中添加本仓库：

```json
{
  "entries": [
    {
      "path": "~/antigravity-skills"
    }
  ]
}
```

---

### 第三步：验证技能加载
启动或重启 Antigravity 会话后，可以在对话中尝试触发技能，或询问：
> "检查我的跨设备技能是否加载"

若能识别 `example-skill` 或 `skills-sync`，即表示链接成功。

---

## 日常同步与协作

- **日常开始工作前**：执行 `pull` 获取其他设备更新的内容。
- **编写新技能后**：在仓库下新建目录并编写 `SKILL.md`，执行 `push` 推送到 GitHub。
- **跨平台换行符说明**：建议保持 Git 默认换行符处理配置（Windows: `core.autocrlf=true`），避免不同操作系统之间的格式差异。
