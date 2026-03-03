#!/usr/bin/env bash
#
# OpenClaw 跨平台安装脚本 (macOS / Linux)
# 功能：自动安装 git、nodejs v24 (通过nvm)，配置国内镜像源，安装 openclaw
# 支持检测更新和自动修复网络问题
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_note() { echo -e "${BLUE}[NOTE]${NC} $1"; }

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

# timeout 兼容函数
_timeout() {
    if command -v timeout &> /dev/null; then
        timeout "$@"
    elif command -v gtimeout &> /dev/null; then
        gtimeout "$@"
    else
        shift
        "$@"
    fi
}

# 检测网络是否通畅
check_network() {
    local url=$1
    if _timeout 5 curl -sf "$url" &> /dev/null; then
        return 0
    fi
    return 1
}

# ============ 修复 Debian EOL 源 ============
fix_debian_sources() {
    if [ ! -f /etc/os-release ]; then
        return 0
    fi

    . /etc/os-release

    if [ "$ID" != "debian" ]; then
        return 0
    fi

    local codename="$VERSION_CODENAME"
    local eol_versions="buster stretch jessie wheezy"

    for eol in $eol_versions; do
        if [ "$codename" = "$eol" ]; then
            log_warn "检测到 Debian $codename 已停止维护，正在修复软件源..."
            cat > /etc/apt/sources.list << EOF
deb http://archive.debian.org/debian $codename main contrib non-free
deb http://archive.debian.org/debian-security $codename/updates main contrib non-free
EOF
            log_info "软件源已修复"
            return 0
        fi
    done
}

# 从终端读取输入（支持管道模式）
read_input() {
    local prompt="$1"
    if [ -t 0 ]; then
        read -p "$prompt" -r REPLY
    elif [ -e /dev/tty ]; then
        read -p "$prompt" -r REPLY < /dev/tty
    else
        REPLY=""
        return 1
    fi
    return 0
}

# ============ Xcode 检测与安装 (macOS) ============
check_xcode() {
    local os=$(detect_os)
    if [ "$os" != "macos" ]; then
        return 0
    fi

    if xcode-select -p &> /dev/null; then
        log_info "Xcode 命令行工具已安装"
        return 0
    fi
    return 1
}

install_xcode() {
    log_warn "Xcode 命令行工具未安装，正在安装..."
    xcode-select --install 2>/dev/null || true
    log_warn "请完成 Xcode 命令行工具安装后重新运行此脚本"
    if read_input "按 Enter 键退出..."; then
        :
    fi
    exit 1
}

# ============ Git 安装/检测 ============
check_git() {
    if command -v git &> /dev/null; then
        log_info "Git 已安装: $(git --version)"
        return 0
    fi
    return 1
}

install_git() {
    local os=$(detect_os)
    log_warn "Git 未安装，正在安装..."

    case $os in
        macos)
            xcode-select --install 2>/dev/null || true
            if command -v brew &> /dev/null; then
                brew install git
            else
                log_error "请先安装 Homebrew: https://brew.sh"
                exit 1
            fi
            ;;
        linux|wsl)
            if command -v apt-get &> /dev/null; then
                fix_debian_sources
                sudo apt-get update && sudo apt-get install -y git curl ca-certificates
            elif command -v yum &> /dev/null; then
                sudo yum install -y git curl ca-certificates
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y git curl ca-certificates
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm git curl
            else
                log_error "无法识别 Linux 发行版，请手动安装 Git"
                exit 1
            fi
            ;;
        windows)
            log_warn "Windows 环境请使用 install-openclaw.ps1 脚本"
            exit 1
            ;;
    esac
    log_info "Git 安装完成"
}

# ============ NVM/Node.js 安装 ============
check_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        return 0
    fi
    return 1
}

check_nodejs() {
    if command -v node &> /dev/null; then
        local version=$(node -v | sed 's/v//' | cut -d. -f1)
        echo "$version"
        return 0
    fi
    return 1
}

install_nvm() {
    log_info "正在安装 NVM..."

    export NVM_DIR="$HOME/.nvm"

    local install_success=false

    local nvm_install_url="https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh"
    if check_network "https://github.com"; then
        log_info "从 GitHub 下载 NVM..."
        if curl -o- "$nvm_install_url" 2>/dev/null | bash; then
            install_success=true
        fi
    fi

    if [ "$install_success" = false ]; then
        log_warn "尝试使用 jsDelivr CDN..."
        local jsdelivr_url="https://cdn.jsdelivr.net/gh/nvm-sh/nvm@v0.40.4/install.sh"
        if curl -o- "$jsdelivr_url" 2>/dev/null | bash; then
            install_success=true
        fi
    fi

    if [ "$install_success" = false ]; then
        log_warn "尝试使用 fastgit 镜像..."
        local fastgit_url="https://hub.fastgit.xyz/nvm-sh/nvm/raw/v0.40.4/install.sh"
        if curl -o- "$fastgit_url" 2>/dev/null | bash; then
            install_success=true
        fi
    fi

    if [ "$install_success" = false ]; then
        log_warn "尝试使用 gitclone 镜像..."
        local gitclone_url="https://gitclone.com/github.com/nvm-sh/nvm/raw/v0.40.4/install.sh"
        if curl -o- "$gitclone_url" 2>/dev/null | bash; then
            install_success=true
        fi
    fi

    if [ "$install_success" = false ]; then
        log_error "无法下载 NVM，请检查网络或手动安装"
        log_info "手动安装: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"
        exit 1
    fi

    log_info "NVM 安装成功"
}

install_nodejs() {
    local current_ver=$(check_nodejs)

    if [ -n "$current_ver" ] && [ "$current_ver" -ge 24 ]; then
        log_info "Node.js 已安装: $(node -v)"
        return 0
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if ! command -v nvm &> /dev/null; then
        if ! check_nvm; then
            install_nvm
        fi
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    log_info "正在安装 Node.js v24..."

    if ! check_network "https://nodejs.org"; then
        log_warn "nodejs.org 不可达，使用国内镜像..."
        export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"
    fi

    nvm install 24
    nvm use 24
    nvm alias default 24

    log_info "Node.js 安装完成: $(node -v)"
    log_info "NPM 版本: $(npm -v)"
}

# ============ NPM 源配置 ============
configure_npm_source() {
    local registry=$(npm config get registry 2>/dev/null || echo "")

    log_info "检测 NPM 源连接..."

    if [ -n "$registry" ] && check_network "${registry}vue"; then
        log_info "NPM 源可用: $registry"
        return 0
    fi

    log_warn "NPM 源不可用，尝试切换国内源..."

    local sources=(
        "https://registry.npmmirror.com"
        "https://registry.taobao.org"
    )

    for source in "${sources[@]}"; do
        log_info "尝试源: $source"
        if check_network "$source"; then
            npm config set registry "$source"
            log_info "NPM 源已设置为: $source"
            return 0
        fi
    done

    log_error "无法连接任何 NPM 源"
    return 1
}

# ============ Git 配置 ============
configure_git_https() {
    log_warn "配置 Git 使用 HTTPS 模式..."
    git config --global url."https://github.com/".insteadOf "git@github.com:"
    git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"
    git config --global url."https://".insteadOf "git://"
    log_info "Git 已配置为 HTTPS 模式"
}

configure_git_mirror() {
    log_warn "配置 Git 使用国内镜像..."
    git config --global url."https://gitclone.com/github.com/".insteadOf "https://github.com/"
    git config --global url."https://gitclone.com/github.com/".insteadOf "git@github.com:"
    git config --global url."https://gitclone.com/github.com/".insteadOf "ssh://git@github.com/"
    log_info "Git 已配置为国内镜像"
}

reset_git_config() {
    git config --global --unset url."https://github.com/".insteadOf 2>/dev/null || true
    git config --global --unset url."https://gitclone.com/github.com/".insteadOf 2>/dev/null || true
    git config --global --unset url."https://".insteadOf 2>/dev/null || true
}

# ============ OpenClaw 更新检查 ============
check_openclaw_update() {
    log_info "检查 OpenClaw 更新..."
    
    local current_version=$(openclaw --version 2>/dev/null | head -1 || echo "unknown")
    local latest_info
    
    latest_info=$(npm view openclaw version 2>/dev/null) || {
        log_warn "无法获取最新版本信息，跳过更新检查"
        return 1
    }
    
    local latest_version="$latest_info"
    
    log_note "当前版本: $current_version"
    
    if [ "$current_version" = "$latest_version" ]; then
        log_info "OpenClaw 已是最新版本"
        return 0
    fi
    
    log_note "有新版本可用: $latest_version"
    echo ""
    
    if read_input "是否更新? (y/N): "; then
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            update_openclaw
        else
            log_info "跳过更新"
        fi
    else
        log_warn "无法读取输入，跳过更新"
    fi
}

update_openclaw() {
    log_info "正在更新 OpenClaw..."
    
    local max_retries=3
    local retry_count=0
    local use_https=false
    local use_mirror=false
    
    while [ $retry_count -lt $max_retries ]; do
        retry_count=$((retry_count + 1))
        log_info "更新尝试 $retry_count/$max_retries"
        log_note "npm 正在更新，请耐心等待..."
        
        set +e
        npm update -g openclaw --loglevel=verbose 2>&1 | tee /tmp/openclaw_update.log
        local exit_code=${PIPESTATUS[0]}
        set -e
        
        if [ $exit_code -eq 0 ]; then
            log_info "OpenClaw 更新成功!"
            openclaw --version
            rm -f /tmp/openclaw_update.log
            return 0
        fi
        
        local error_output=$(cat /tmp/openclaw_update.log 2>/dev/null || echo "")
        if echo "$error_output" | grep -qE "Permission denied|Could not read from remote repository|unknown git error|ECONNREFUSED|ETIMEDOUT"; then
            log_warn "检测到网络/Git 访问错误"
            
            configure_npm_source
            
            if [ "$use_https" = false ]; then
                configure_git_https
                use_https=true
                log_info "已切换为 HTTPS 模式，重试更新..."
                continue
            fi
            
            if [ "$use_mirror" = false ]; then
                configure_git_mirror
                use_mirror=true
                log_info "已切换为国内镜像，重试更新..."
                continue
            fi
            
            log_error "所有方式均失败，请检查网络环境"
            rm -f /tmp/openclaw_update.log
            return 1
        fi
        
        log_error "更新失败，请查看上方输出"
        rm -f /tmp/openclaw_update.log
        return 1
    done
    
    log_error "更新失败，已达最大重试次数"
    return 1
}

# ============ OpenClaw 安装 ============
install_openclaw() {
    log_info "正在安装 OpenClaw..."

    local max_retries=3
    local retry_count=0
    local use_https=false
    local use_mirror=false

    while [ $retry_count -lt $max_retries ]; do
        retry_count=$((retry_count + 1))
        log_info "安装尝试 $retry_count/$max_retries"
        log_note "npm 正在安装，请耐心等待..."

        set +e
        npm i -g openclaw --loglevel=verbose 2>&1 | tee /tmp/openclaw_install.log
        local exit_code=${PIPESTATUS[0]}
        set -e

        if [ $exit_code -eq 0 ]; then
            log_info "OpenClaw 安装成功"
            rm -f /tmp/openclaw_install.log
            return 0
        fi

        local error_output=$(cat /tmp/openclaw_install.log 2>/dev/null || echo "")
        if echo "$error_output" | grep -qE "Permission denied|Could not read from remote repository|unknown git error|ECONNREFUSED|ETIMEDOUT"; then
            log_warn "检测到网络/Git 访问错误"

            if [ "$use_https" = false ]; then
                configure_git_https
                use_https=true
                log_info "已切换为 HTTPS 模式，重试安装..."
                continue
            fi

            if [ "$use_mirror" = false ]; then
                configure_git_mirror
                use_mirror=true
                log_info "已切换为国内镜像，重试安装..."
                continue
            fi

            log_error "所有方式均失败，请检查网络环境"
            rm -f /tmp/openclaw_install.log
            return 1
        fi

        log_error "安装失败，请查看上方输出"
        rm -f /tmp/openclaw_install.log
        return 1
    done

    log_error "安装失败，已达最大重试次数"
    return 1
}

# ============ 检测已安装状态 ============
check_all_installed() {
    local has_git=false
    local has_node=false
    local has_openclaw=false
    
    command -v git &> /dev/null && has_git=true
    command -v node &> /dev/null && has_node=true
    command -v openclaw &> /dev/null && has_openclaw=true
    
    if [ "$has_git" = true ] && [ "$has_node" = true ] && [ "$has_openclaw" = true ]; then
        return 0
    fi
    return 1
}

# ============ 主流程 ============
main() {
    local os=$(detect_os)

    echo "========================================"
    echo "  OpenClaw 安装脚本 v1.5"
    echo "  操作系统: $os"
    echo "========================================"
    echo ""

    # 检测是否已全部安装
    if check_all_installed; then
        log_info "检测到 Git、Node.js 和 OpenClaw 均已安装"
        echo ""
        log_info "Git: $(git --version)"
        log_info "Node.js: $(node -v)"
        log_info "OpenClaw: $(openclaw --version 2>/dev/null | head -1 || echo 'installed')"
        echo ""
        
        check_openclaw_update
        echo ""
        
        log_info "如需重新配置，请运行: openclaw onboard"
        
        log_info "完成!"
        exit 0
    fi

    # 1. Xcode 检测 (仅 macOS)
    if [ "$os" = "macos" ]; then
        log_info "步骤 1/5: 检测 Xcode 命令行工具"
        if ! check_xcode; then
            install_xcode
        fi
    fi

    # 2. Git 检测与安装
    log_info "步骤 2/5: 检测 Git"
    if ! check_git; then
        install_git
    fi

    # 3. Node.js 检测与安装 (通过 NVM)
    log_info "步骤 3/5: 检测并安装 Node.js v24"
    install_nodejs

    # 4. NPM 源配置
    log_info "步骤 4/5: 配置 NPM 源"
    configure_npm_source

    # 5. 安装 OpenClaw
    log_info "步骤 5/5: 安装 OpenClaw"

    if command -v openclaw &> /dev/null; then
        log_warn "OpenClaw 已安装"
        if read_input "是否重新安装? (y/N): "; then
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                reset_git_config
                if ! install_openclaw; then
                    exit 1
                fi
            fi
        fi
    else
        if ! install_openclaw; then
            exit 1
        fi
    fi

    # 验证安装
    if ! command -v openclaw &> /dev/null; then
        log_error "OpenClaw 安装失败"
        exit 1
    fi

    echo ""
    echo "========================================"
    log_info "OpenClaw 安装成功!"
    openclaw -v
    echo "========================================"
    echo ""
    
    log_info "配置环境变量..."
    local npm_bin=$(npm config get prefix 2>/dev/null)
    if [ -n "$npm_bin" ]; then
        local path_updated=false
        local shell_rc=""
        
        if [ -n "$ZSH_VERSION" ]; then
            shell_rc="$HOME/.zshrc"
        elif [ -n "$BASH_VERSION" ]; then
            shell_rc="$HOME/.bashrc"
        else
            shell_rc="$HOME/.profile"
        fi
        
        if [ -f "$shell_rc" ]; then
            if ! grep -q "export PATH=\"\$PATH:$npm_bin\"" "$shell_rc" 2>/dev/null; then
                echo "" >> "$shell_rc"
                echo "# Added by OpenClaw installer" >> "$shell_rc"
                echo "export PATH=\"\$PATH:$npm_bin\"" >> "$shell_rc"
                path_updated=true
            fi
        fi
        
        if [ "$path_updated" = true ]; then
            log_info "已将 npm 全局目录添加到 PATH: $npm_bin"
        else
            log_info "npm 全局目录已在 PATH 配置中"
        fi
    fi
    
    export PATH="$PATH:$(npm config get prefix 2>/dev/null)"
    
    echo ""
    echo "========================================"
    log_info "全部完成!"
    log_note "现在运行: openclaw onboard"
    log_note "新终端窗口也可直接使用 openclaw 命令"
    echo "========================================"
}

SCRIPT_PATH="$0"

cleanup() {
    rm -f "$SCRIPT_PATH" 2>/dev/null || true
}

trap cleanup EXIT

# 执行主流程
main "$@"
