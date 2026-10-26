#!/usr/bin/env bash
#
# 跨设备 Antigravity Skills 同步与管理脚本 (Linux / macOS / WSL)
# 用法:
#   ./sync-skills.sh [status|pull|push|init] [commit_message]
#

set -e

ACTION="${1:-status}"
MESSAGE="${2:-chore: sync skills at $(date '+%Y-%m-%d %H:%M:%S')}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="$HOME/.gemini/config"
CONFIG_FILE="$CONFIG_DIR/skills.json"

cd "$REPO_ROOT"

case "$ACTION" in
  status)
    echo "=== 检查本地技能规范 ==="
    for dir in "$REPO_ROOT"/*/; do
      dir_name="$(basename "$dir")"
      if [[ "$dir_name" == .* ]]; then
        continue
      fi
      if [[ -f "$dir/SKILL.md" ]]; then
        if grep -q "^name:" "$dir/SKILL.md" && grep -q "^description:" "$dir/SKILL.md"; then
          echo "  [OK] $dir_name"
        else
          echo "  [WARN] $dir_name - SKILL.md 缺少必要 frontmatter 字段"
        fi
      else
        echo "  [WARN] $dir_name - 缺少 SKILL.md"
      fi
    done

    echo ""
    echo "=== 检查 ~/.gemini/config/skills.json 链接状态 ==="
    if [[ -f "$CONFIG_FILE" ]]; then
      echo "  [OK] skills.json 存在: $CONFIG_FILE"
      if grep -q "antigravity-skills" "$CONFIG_FILE"; then
        echo "  [OK] 已包含 antigravity-skills 引用"
      else
        echo "  [WARN] 尚未引用 antigravity-skills，可执行 ./sync-skills.sh init"
      fi
    else
      echo "  [WARN] 未检测到 skills.json，可执行 ./sync-skills.sh init"
    fi

    echo ""
    echo "=== Git 状态 ==="
    git status -s
    ;;

  pull)
    echo "=== 从远程拉取最新技能 ==="
    git pull origin main
    ;;

  push)
    echo "=== 提交并推送技能 ==="
    git add -A
    if git diff --cached --quiet; then
      echo "没有需要提交的更改。"
    else
      git commit -m "$MESSAGE"
      git push origin main
      echo "推送完成！"
    fi
    ;;

  init)
    echo "=== 初始化本地 skills.json 配置 ==="
    mkdir -p "$CONFIG_DIR"
    cat <<EOF > "$CONFIG_FILE"
{
  "entries": [
    {
      "path": "~/antigravity-skills"
    }
  ]
}
EOF
    echo "已成功生成 $CONFIG_FILE"
    ;;

  *)
    echo "未知操作: $ACTION"
    echo "可选操作: status | pull | push | init"
    exit 1
    ;;
esac
