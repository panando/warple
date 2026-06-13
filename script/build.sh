#!/bin/bash
set -euo pipefail

# ============================================================
# Warple 完整构建脚本 — 编译 + 打包为 DMG
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 读取版本号
VERSION_FILE="${PROJECT_DIR}/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
    echo "❌ 未找到 VERSION 文件: $VERSION_FILE"
    exit 1
fi
APP_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')

echo "=========================================="
echo "  Warple 构建脚本 v${APP_VERSION}"
echo "=========================================="
echo ""

# ---- 1. 编译 ----
echo "🔨 [1/2] 编译 warp-oss..."
echo ""

cd "$PROJECT_DIR"

cargo build --release --bin warp-oss \
    --no-default-features \
    --features "release_bundle,gui,local_tty,local_fs,shell_selector,ligatures,rect_selection,markdown_tables,settings_file"

echo ""
echo "✅ 编译完成"
echo ""

# ---- 2. 打包 ----
echo "📦 [2/2] 打包为 macOS 应用..."
echo ""

bash script/package-warple.sh

echo ""
echo "=========================================="
echo "  构建完成！"
echo "=========================================="
echo ""
echo "📁 产物位置:"
echo ""
echo "  App:  ${PROJECT_DIR}/dist/Warple.app"
echo "  DMG:  ${PROJECT_DIR}/dist/Warple.dmg"
echo ""
echo "💡 安装方式:"
echo "  1. 双击 dist/Warple.dmg"
echo "  2. 将 Warple 拖入 Applications 文件夹"
echo "  3. 首次打开需右键 → 打开（绕过 Gatekeeper）"
echo ""
