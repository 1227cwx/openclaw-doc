# ==========================================
# 1. 环境编码修复 (必须放在最顶部)
# ==========================================
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
if ($Host.Name -eq "ConsoleHost") { chcp 65001 | Out-Null }

$ErrorActionPreference = "Stop"

# ==========================================
# 2. 日志与工具函数
# ==========================================
function Log-Info { param($msg) Write-Host "[信息] $msg" -ForegroundColor Green }
function Log-Warn { param($msg) Write-Host "[警告] $msg" -ForegroundColor Yellow }
function Log-Error { param($msg) Write-Host "[错误] $msg" -ForegroundColor Red }
function Log-Note { param($msg) Write-Host "[提示] $msg" -ForegroundColor Cyan }

function Remove-Self {
    param($scriptPath)
    if ($scriptPath -and (Test-Path $scriptPath)) {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c timeout /t 2 >nul & del /f /q `"$scriptPath`"" -WindowStyle Hidden -ErrorAction SilentlyContinue
    }
}

function Read-Input {
    param($prompt)
    try {
        Write-Host -NoNewline $prompt -ForegroundColor Cyan
        return [Console]::ReadLine()
    } catch {
        return $null
    }
}

function Test-Network {
    param($url)
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Timeout = 5000
        $req.GetResponse() | Out-Null
        return $true
    } catch {
        return $false
    }
}

# ==========================================
# 3. 环境检测与安装逻辑
# ==========================================
function Check-Git {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        git config --global core.quotepath false
        return $true
    }
    return $false
}

function Install-Git {
    Log-Warn "Git 未安装，正在尝试自动安装..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install git -y
    } else {
        Log-Error "未能找到 winget 或 chocolatey。请手动安装 Git。"
        exit 1
    }
    Log-Info "Git 安装已启动，请完成后重启终端再次运行。"
    exit 0
}

function Check-Nodejs {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $version = (node -v) -replace 'v', '' -split '\.' | Select-Object -First 1
        return [int]$version
    }
    return 0
}

function Install-Nvm {
    Log-Info "正在下载 NVM 管理器..."
    $nvmUrl = "https://github.com/coreybutler/nvm-windows/releases/download/1.2.2/nvm-setup.exe"
    $mirrorUrl = "https://npmmirror.com/mirrors/nvm/1.2.2/nvm-setup.exe"
    $downloadUrl = if (Test-Network "https://github.com") { $nvmUrl } else { $mirrorUrl }
    $tempFile = "$env:TEMP\nvm-setup.exe"

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
        Log-Info "请在弹出的窗口中完成 NVM 安装..."
        Start-Process -FilePath $tempFile -Wait
        Log-Warn "NVM 安装完成，请重新打开终端再次运行脚本。"
        exit 0
    } catch {
        Log-Error "NVM 下载失败: $_"
        exit 1
    }
}

function Install-Nodejs {
    $currentVer = Check-Nodejs
    if ($currentVer -ge 24) { return }
    if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) { Install-Nvm; return }

    Log-Info "正在安装 Node.js v24..."
    nvm node_mirror https://npmmirror.com/mirrors/node/
    nvm install 24
    nvm use 24
}

# ==========================================
# 4. OpenClaw 安装与更新
# ==========================================
function Configure-NpmSource {
    if (Test-Network "https://registry.npmmirror.com") {
        npm config set registry https://registry.npmmirror.com
        Log-Info "已切换至国内 NPM 镜像源"
    }
}

function Get-LatestVersion {
    try {
        $latest = npm view openclaw version 2>$null
        if ($latest) { return $latest.Trim() }
    } catch {}
    return $null
}

function Check-OpenClaw-Update {
    Log-Info "检查 OpenClaw 更新..."
    
    $currentVersion = (openclaw --version 2>$null | Select-Object -First 1) -replace '\s',''
    $latestVersion = Get-LatestVersion
    
    if (-not $latestVersion) {
        Log-Warn "无法获取最新版本信息，跳过更新检查"
        return
    }
    
    Log-Note "当前版本: $currentVersion"
    
    if ($currentVersion -eq $latestVersion) {
        Log-Info "OpenClaw 已是最新版本"
        return
    }
    
    Log-Note "有新版本可用: $latestVersion"
    Write-Host ""
    
    $reply = Read-Input "是否更新? (y/N): "
    if ($reply -match '^[Yy]$') {
        Update-OpenClaw
    } else {
        Log-Info "跳过更新"
    }
}

function Update-OpenClaw {
    Log-Info "正在更新 OpenClaw..."
    Log-Note "npm 正在更新，请耐心等待..."
    
    npm install -g openclaw@latest --loglevel verbose
    
    if ($LASTEXITCODE -eq 0) {
        Log-Info "OpenClaw 更新成功!"
        openclaw --version
        return $true
    }
    
    Log-Error "更新失败"
    return $false
}

function Install-OpenClaw {
    Log-Info "正在安装 OpenClaw..."
    Log-Note "npm 正在安装，请耐心等待..."
    
    npm i -g openclaw --loglevel verbose
    
    if ($LASTEXITCODE -eq 0) {
        Log-Info "OpenClaw 安装成功"
        return $true
    }
    
    Log-Error "安装失败"
    return $false
}

# ==========================================
# 5. 检测已安装状态
# ==========================================
function Check-All-Installed {
    $hasGit = Get-Command git -ErrorAction SilentlyContinue
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    $hasOpenClaw = Get-Command openclaw -ErrorAction SilentlyContinue
    
    return ($hasGit -and $hasNode -and $hasOpenClaw)
}

# ==========================================
# 6. 主程序
# ==========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw Windows 自动安装程序 v1.5" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Check-All-Installed) {
    Log-Info "检测到 Git、Node.js 和 OpenClaw 均已安装"
    Write-Host ""
    Log-Info "Git: $(git --version)"
    Log-Info "Node.js: $(node -v)"
    Log-Info "OpenClaw: $(openclaw --version 2>$null | Select-Object -First 1)"
    Write-Host ""
    
    Check-OpenClaw-Update
    Write-Host ""
    
    Log-Info "如需重新配置，请运行: openclaw onboard"
    Log-Info "完成!"
    
    Remove-Self $PSCommandPath
    exit 0
}

Log-Info "步骤 1/4: 检测 Git"
if (-not (Check-Git)) { Install-Git }

Log-Info "步骤 2/4: 检测并安装 Node.js v24"
Install-Nodejs

Log-Info "步骤 3/4: 配置 NPM 源"
Configure-NpmSource

Log-Info "步骤 4/4: 安装 OpenClaw"

if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    Log-Warn "OpenClaw 已安装"
    $reply = Read-Input "是否重新安装? (y/N): "
    if ($reply -match '^[Yy]$') {
        if (-not (Install-OpenClaw)) { exit 1 }
    }
} else {
    if (-not (Install-OpenClaw)) { exit 1 }
}

if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) {
    Log-Error "OpenClaw 安装失败"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Log-Info "OpenClaw 安装成功!"
openclaw -v
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Log-Info "配置环境变量..."
$npmBinPath = npm config get prefix
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

if ($currentPath -notlike "*$npmBinPath*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$npmBinPath", "User")
    $env:PATH = "$env:PATH;$npmBinPath"
    Log-Info "已将 npm 全局目录添加到 PATH: $npmBinPath"
} else {
    Log-Info "npm 全局目录已在 PATH 中"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Log-Info "全部完成!"
Log-Note "现在运行: openclaw onboard"
Log-Note "新终端窗口也可直接使用 openclaw 命令"
Write-Host "========================================" -ForegroundColor Green

Remove-Self $PSCommandPath
