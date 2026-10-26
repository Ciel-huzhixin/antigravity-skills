<#
.SYNOPSIS
    跨设备 Antigravity Skills 同步与管理脚本 (Windows PowerShell)
.DESCRIPTION
    支持检查技能结构、一键拉取远端更新、提交推送以及配置本地 skills.json。
.PARAMETER Action
    操作类型：status（默认）、pull、push、init
.PARAMETER Message
    Git 提交说明（仅在 push 时使用）
#>

param (
    [ValidateSet("status", "pull", "push", "init")]
    [string]$Action = "status",

    [string]$Message = ""
)

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ConfigDir = Join-Path $HOME ".gemini\config"
$ConfigFile = Join-Path $ConfigDir "skills.json"

function Test-SkillValid([string]$SkillDir) {
    $SkillMd = Join-Path $SkillDir "SKILL.md"
    if (-not (Test-Path $SkillMd)) {
        return @{ Valid = $false; Reason = "缺少 SKILL.md 文件" }
    }
    $content = Get-Content -Path $SkillMd -Raw -Encoding UTF8
    if ($content -notmatch '(?s)^---\s*\r?\n(.*?)\r?\n---') {
        return @{ Valid = $false; Reason = "SKILL.md 缺少 YAML Frontmatter" }
    }
    $frontmatter = $matches[1]
    if ($frontmatter -notmatch 'name:\s*\S+') {
        return @{ Valid = $false; Reason = "YAML Frontmatter 缺少 name 字段" }
    }
    if ($frontmatter -notmatch 'description:\s*\S+') {
        return @{ Valid = $false; Reason = "YAML Frontmatter 缺少 description 字段" }
    }
    return @{ Valid = $true; Reason = "规范正常" }
}

Push-Location $RepoRoot
try {
    switch ($Action) {
        "status" {
            Write-Host "=== 检查本地技能规范 ===" -ForegroundColor Cyan
            $subdirs = Get-ChildItem -Directory | Where-Object { $_.Name -notmatch '^\.' }
            $hasError = $false
            foreach ($dir in $subdirs) {
                $check = Test-SkillValid -SkillDir $dir.FullName
                if ($check.Valid) {
                    Write-Host "  [OK] $($dir.Name)" -ForegroundColor Green
                } else {
                    Write-Host "  [WARN] $($dir.Name) - $($check.Reason)" -ForegroundColor Yellow
                    $hasError = $true
                }
            }

            Write-Host "`n=== 检查 ~/.gemini/config/skills.json 链接状态 ===" -ForegroundColor Cyan
            if (Test-Path $ConfigFile) {
                Write-Host "  [OK] skills.json 已存在: $ConfigFile" -ForegroundColor Green
                $json = Get-Content -Raw -Path $ConfigFile -Encoding UTF8
                if ($json -match 'antigravity-skills') {
                    Write-Host "  [OK] 已包含 antigravity-skills 路径引用" -ForegroundColor Green
                } else {
                    Write-Host "  [WARN] 尚未引用 antigravity-skills，可执行 -Action init 添加" -ForegroundColor Yellow
                }
            } else {
                Write-Host "  [WARN] 未检测到 skills.json，可执行 -Action init 初始化" -ForegroundColor Yellow
            }

            Write-Host "`n=== Git 状态 ===" -ForegroundColor Cyan
            git status -s
        }

        "pull" {
            Write-Host "=== 从远程拉取最新技能 ===" -ForegroundColor Cyan
            git pull origin main
        }

        "push" {
            if ([string]::IsNullOrWhiteSpace($Message)) {
                $Message = "chore: sync skills at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            }
            Write-Host "=== 提交并推送技能 ===" -ForegroundColor Cyan
            git add -A
            $status = git status --porcelain
            if (-not $status) {
                Write-Host "没有需要提交的更改。" -ForegroundColor Yellow
                return
            }
            git commit -m "$Message"
            git push origin main
            Write-Host "推送完成！" -ForegroundColor Green
        }

        "init" {
            Write-Host "=== 初始化本地 skills.json 配置 ===" -ForegroundColor Cyan
            if (-not (Test-Path $ConfigDir)) {
                New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
            }
            $configData = @{
                entries = @(
                    @{ path = "~/antigravity-skills" }
                )
            }
            $jsonContent = $configData | ConvertTo-Json -Depth 5
            Set-Content -Path $ConfigFile -Value $jsonContent -Encoding UTF8
            Write-Host "已更新配置文件: $ConfigFile" -ForegroundColor Green
            Write-Host $jsonContent
        }
    }
}
finally {
    Pop-Location
}
