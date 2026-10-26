# Antigravity Skills 跨设备技能库

这是跨设备共享的 Antigravity 自定义技能（Skills）仓库，支持在 Windows、macOS 和 Linux 设备间快速同步与集中管理。

---

## 仓库结构

每个技能在根目录下拥有独立的子文件夹，并遵循 Antigravity 技能规范：

```text
antigravity-skills/
├── example-skill/              # 示例验证技能
│   └── SKILL.md
├── skills-sync/                # 跨设备技能管理与同步助手
│   ├── SKILL.md
│   ├── scripts/                # 多端同步自动化脚本 (.ps1 / .sh)
│   └── references/             # 详细配置与多端接入指南
├── lean-frontend-coding/       # 精益前端开发规范（拒绝过度防御）
│   ├── SKILL.md
│   └── examples/               # 常见 Bad vs Good 案例对比
└── README.md
```

---

## 技能列表

| 技能名称 | 说明 | 适用场景 |
| :--- | :--- | :--- |
| [`example-skill`](./example-skill/SKILL.md) | 基础验证技能 | 验证 Antigravity 是否成功加载跨设备仓库中的技能 |
| [`skills-sync`](./skills-sync/SKILL.md) | 技能同步与多端管理 | 检查技能规范、一键拉取/推送更新、新设备初始化配置 |
| [`lean-frontend-coding`](./lean-frontend-coding/SKILL.md) | 精益前端代码规范 | 拒绝前端过度防御与多重字段猜测兜底（`||` 滥用），倡导契约优先与主动确认 |

---

## 在新设备上快速接入

1. **克隆本仓库到用户目录**：
   ```bash
   git clone https://github.com/Ciel-huzhixin/antigravity-skills.git ~/antigravity-skills
   ```

2. **配置全局技能清单 (`~/.gemini/config/skills.json`)**：
   可以直接运行一键初始化脚本：
   - **Windows (PowerShell)**：
     ```powershell
     & "$HOME\antigravity-skills\skills-sync\scripts\sync-skills.ps1" -Action init
     ```
   - **macOS / Linux**：
     ```bash
     bash ~/antigravity-skills/skills-sync/scripts/sync-skills.sh init
     ```
   或者手动编辑 `~/.gemini/config/skills.json`：
   ```json
   {
     "entries": [
       { "path": "~/antigravity-skills" }
     ]
   }
   ```

3. **更多详细指引**：
   请参考 [多设备配置指南](./skills-sync/references/multi-device-setup.md)。
