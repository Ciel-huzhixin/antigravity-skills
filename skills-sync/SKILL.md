---
name: skills-sync
description: >-
  用于管理和跨设备同步 Antigravity 自定义技能（Skills）。当用户需要同步技能库、更新远程仓库、从 GitHub 拉取最新技能、向仓库提交新技能或检查多端配置时使用此技能。
---

# 技能跨设备同步与管理 (Skills Sync & Management)

本技能提供跨设备管理与同步 Antigravity Skills 的完整流程，帮助你在多台电脑（Windows/macOS/Linux）之间保持自定义技能的一致性。

## 技能目录位置

默认安装路径：
- Windows: `~/antigravity-skills` (`$HOME\antigravity-skills`)
- Linux / macOS: `~/antigravity-skills`

全局配置文件：
- 路径：`~/.gemini/config/skills.json`
- 配置项：
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

## 常用操作流程

### 1. 从远程仓库拉取更新 (Pull)
当在其他设备上添加或修改了技能，需要在当前设备获取最新版本时：

- **Windows (PowerShell)**:
  ```powershell
  & "$HOME\antigravity-skills\skills-sync\scripts\sync-skills.ps1" -Action pull
  ```
- **macOS / Linux (Bash)**:
  ```bash
  bash ~/antigravity-skills/skills-sync/scripts/sync-skills.sh pull
  ```

### 2. 检查技能规范与状态 (Status)
在提交新技能前，检查技能结构是否合法（必须包含 `SKILL.md` 且拥有 `name` 与 `description` frontmatter）：

- **Windows**:
  ```powershell
  & "$HOME\antigravity-skills\skills-sync\scripts\sync-skills.ps1" -Action status
  ```
- **macOS / Linux**:
  ```bash
  bash ~/antigravity-skills/skills-sync/scripts/sync-skills.sh status
  ```

### 3. 提交并推送新技能到远程仓库 (Push)
当你在当前设备创建或修改了技能并希望同步到所有设备时：

- **Windows**:
  ```powershell
  & "$HOME\antigravity-skills\skills-sync\scripts\sync-skills.ps1" -Action push -Message "feat: add my-new-skill"
  ```
- **macOS / Linux**:
  ```bash
  bash ~/antigravity-skills/skills-sync/scripts/sync-skills.sh push "feat: add my-new-skill"
  ```

---

## 新技能创建规范

每个新增技能需在仓库根目录新建同名文件夹，规范如下：

```text
antigravity-skills/
└── <skill-name>/
    ├── SKILL.md          # 必选：技能主体与元数据说明
    ├── scripts/          # 可选：自动化脚本（.ps1/.sh/Python等）
    └── references/       # 可选：长文档、API参考或说明
```

### `SKILL.md` 模板：
```markdown
---
name: your-skill-name
description: >-
  清晰描述技能的功能和适用场景（第三人称）。在什么条件下触发此技能。
---

# 技能名称

## 适用场景
...

## 具体步骤与指令
...
```

---

## 详细指南
更多新设备初始化与配置排查，请参阅：
[多设备配置指南](./references/multi-device-setup.md)
