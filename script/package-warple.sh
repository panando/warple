#!/bin/bash
set -euo pipefail

# ============================================================
# Warple 打包脚本 — 将 warp-oss 二进制打包为 macOS .app 并生成 .dmg
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_NAME="Warple"
APP_BUNDLE_ID="dev.warp.Warple"
BINARY_NAME="warp-oss"
ICON_SRC="${PROJECT_DIR}/app/channels/oss/icon/no-padding/512x512.png"
STABLE_ICONS="${PROJECT_DIR}/app/channels/stable/icon/no-padding"

# 版本号 (从 VERSION 文件读取)
VERSION_FILE="${PROJECT_DIR}/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
    echo "❌ 未找到 VERSION 文件: $VERSION_FILE"
    exit 1
fi
APP_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
BUILD_NUMBER=$(echo "$APP_VERSION" | sed 's/\.//g')

# 输出路径
DIST_DIR="${PROJECT_DIR}/dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"
DMG_PATH="${DIST_DIR}/${APP_NAME}.dmg"
BINARY_PATH="${PROJECT_DIR}/target/release/${BINARY_NAME}"

echo "=========================================="
echo "  Warple 打包工具 v${APP_VERSION}"
echo "=========================================="

# ---- 1. 检查前置条件 ----
if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ 未找到二进制文件: $BINARY_PATH"
    echo "   请先编译: cargo build --release --bin warp-oss --no-default-features --features \"release_bundle,gui,local_tty,local_fs,shell_selector,ligatures,rect_selection,markdown_tables,settings_file\""
    exit 1
fi

for cmd in iconutil hdiutil sips; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ 缺少工具: $cmd"
        exit 1
    fi
done

echo "✓ 前置条件检查通过"

# ---- 2. 清理旧的构建产物 ----
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# ---- 3. 创建 .app 目录结构 ----
echo "📦 创建 .app 目录结构..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
mkdir -p "${APP_BUNDLE}/Contents/Frameworks"

# ---- 4. 复制二进制文件 ----
echo "📋 复制二进制文件..."
cp "$BINARY_PATH" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# ---- 5. 生成 icns 图标 ----
echo "🎨 生成应用图标..."
ICONSET_DIR="${DIST_DIR}/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"

# 使用 sips 从 512x512 PNG 生成各尺寸图标
if [ -f "$ICON_SRC" ]; then
    SRC_PNG="$ICON_SRC"
elif [ -f "${STABLE_ICONS}/512x512.png" ]; then
    SRC_PNG="${STABLE_ICONS}/512x512.png"
else
    echo "⚠️  未找到图标源文件，使用默认图标"
    SRC_PNG=""
fi

if [ -n "$SRC_PNG" ]; then
    sips -z 16 16     "$SRC_PNG" --out "${ICONSET_DIR}/icon_16x16.png"         >/dev/null 2>&1
    sips -z 32 32     "$SRC_PNG" --out "${ICONSET_DIR}/icon_16x16@2x.png"      >/dev/null 2>&1
    sips -z 32 32     "$SRC_PNG" --out "${ICONSET_DIR}/icon_32x32.png"         >/dev/null 2>&1
    sips -z 64 64     "$SRC_PNG" --out "${ICONSET_DIR}/icon_32x32@2x.png"      >/dev/null 2>&1
    sips -z 128 128   "$SRC_PNG" --out "${ICONSET_DIR}/icon_128x128.png"       >/dev/null 2>&1
    sips -z 256 256   "$SRC_PNG" --out "${ICONSET_DIR}/icon_128x128@2x.png"    >/dev/null 2>&1
    sips -z 256 256   "$SRC_PNG" --out "${ICONSET_DIR}/icon_256x256.png"       >/dev/null 2>&1
    sips -z 512 512   "$SRC_PNG" --out "${ICONSET_DIR}/icon_256x256@2x.png"    >/dev/null 2>&1
    sips -z 512 512   "$SRC_PNG" --out "${ICONSET_DIR}/icon_512x512.png"       >/dev/null 2>&1
    sips -z 1024 1024 "$SRC_PNG" --out "${ICONSET_DIR}/icon_512x512@2x.png"    >/dev/null 2>&1

    iconutil -c icns "$ICONSET_DIR" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
    echo "✓ 图标已生成"
else
    echo "⚠️  跳过图标生成"
fi

# ---- 6. 创建 Info.plist ----
echo "📝 生成 Info.plist..."
cat > "${APP_BUNDLE}/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Warple</string>
    <key>CFBundleIdentifier</key>
    <string>dev.warp.Warple</string>
    <key>CFBundleName</key>
    <string>Warple</string>
    <key>CFBundleDisplayName</key>
    <string>Warple</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.developer-tools</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Warp. All rights reserved.</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Shell Script</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.shell-script</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
PLIST

echo "✓ Info.plist 已生成"

# ---- 7. 创建 PkgInfo ----
echo "APPL????" > "${APP_BUNDLE}/Contents/PkgInfo"

# ---- 8. 验证 .app ----
APP_SIZE=$(du -sh "$APP_BUNDLE" | cut -f1)
echo "✓ .app 已创建: ${APP_BUNDLE} (${APP_SIZE})"

# ---- 9. 创建 .dmg ----
echo "📀 创建 DMG 安装镜像..."

DMG_STAGING="${DIST_DIR}/dmg_staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"

# 复制 .app 到 DMG 暂存区
cp -R "$APP_BUNDLE" "$DMG_STAGING/"

# 创建 Applications 快捷方式
ln -s /Applications "${DMG_STAGING}/Applications"

# 创建 DMG
hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "$DMG_STAGING" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

rm -rf "$DMG_STAGING"

DMG_SIZE=$(du -sh "$DMG_PATH" | cut -f1)
echo ""
echo "=========================================="
echo "  ✅ 打包完成!"
echo "=========================================="
echo ""
echo "  .app:  ${APP_BUNDLE} (${APP_SIZE})"
echo "  .dmg:  ${DMG_PATH} (${DMG_SIZE})"
echo ""
echo "  安装方式:"
echo "    1. 双击 ${DMG_PATH} 打开"
echo "    2. 将 Warple 拖入 Applications 文件夹"
echo "    3. 从启动台或 Applications 打开 Warple"
echo ""
