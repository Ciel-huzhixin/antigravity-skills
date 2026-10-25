# Antigravity Skills

这是我的跨设备共享 Antigravity Skills 仓库。

## 目录结构

每个 Skill 在本目录下拥有独立的子文件夹，并包含 `SKILL.md`：

```text
antigravity-skills/
├── example-skill/
│   └── SKILL.md
└── <your-skill-name>/
    └── SKILL.md
```

## 在新设备上同步与启用

1. 克隆本仓库到新设备的用户目录：
   ```bash
   git clone <本仓库URL> ~/antigravity-skills
   ```
2. 在新设备的全局配置 `~/.gemini/config/skills.json` 中配置：
   ```json
   {
     "entries": [
       { "path": "~/antigravity-skills" }
     ]
   }
   ```
