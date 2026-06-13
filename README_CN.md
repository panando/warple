# Warple

**Warple** = **Warp** **L**ocal **E**dition

[Warp](https://github.com/warpdotdev/warp) 终端的精简本地版本 —— 为希望获得纯净终端 GUI、无需云服务、AI 功能或登录提示的用户打造。

[English](README.md)

---

## 关于本项目

本项目来源于 [Warp 官方开源项目](https://github.com/warpdotdev/warp)。

**Warple** 面向以下用户：
- 希望完全本地使用 Warp 的终端窗口
- 不希望被在线功能打扰
- 不需要 AI 功能

## 移除的功能

| 功能 | 状态 |
|------|------|
| 登录 / 注册 | 已禁用 |
| Warp AI | 已禁用 |
| Warp Drive | 已禁用 |
| 云同步 | 已禁用 |
| 计费系统 | 已禁用 |
| Agent 模式 | 已禁用 |

## 保留的功能

- 现代终端模拟器
- GPU 加速渲染
- 字体连字支持
- 矩形选择
- Markdown 表格渲染
- 本地设置持久化
- Shell 选择器

## 编译

详细说明请参阅 [WARPLE_BUILD_GUIDE.md](WARPLE_BUILD_GUIDE.md)。

```bash
# 编译
cargo build --release --bin warp-oss \
  --no-default-features \
  --features "release_bundle,gui,local_tty,local_fs,shell_selector,ligatures,rect_selection,markdown_tables,settings_file"

# 打包 (macOS)
bash script/package-warple.sh
```

## 参与贡献

欢迎报告 Bug 和提出改进建议！请提交 Issue 或 Pull Request。

## 许可证

本项目继承上游 Warp 仓库的许可证：
- UI 框架 (`warpui_core`, `warpui`): MIT 许可证
- 其余代码: AGPL v3

## 致谢

- [Warp](https://www.warp.dev) — Warple 基于的原始终端项目
- 所有让这一切成为可能的开源依赖项目
