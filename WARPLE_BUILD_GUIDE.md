# Warple — 从 Warp 官方版本到本地精简版完整操作流程

## 概述

本文档记录了从 Warp 官方仓库构建本地精简版终端（Warple）的完整流程，包括代码修改、编译、打包和分发。

**目标产物**: 一个无需账户登录、无云端服务依赖的本地终端应用。

---

## 1. 获取源码

```bash
git clone https://github.com/warpdotdev/warp.git warpl
cd warpl
```

> 需要 Rust 工具链（rustup）、Xcode Command Line Tools。

---

## 2. 编译命令

```bash
cargo build --release --bin warp-oss \
  --no-default-features \
  --features "release_bundle,gui,local_tty,local_fs,shell_selector,ligatures,rect_selection,markdown_tables,settings_file"
```

**Feature 说明**:

| Feature | 作用 |
|---------|------|
| `release_bundle` | 发布模式资源打包 |
| `gui` | GPU 渲染 GUI |
| `local_tty` | 本地终端模拟 |
| `local_fs` | 本地文件系统访问 |
| `shell_selector` | Shell 选择器 |
| `ligatures` | 字体连字支持 |
| `rect_selection` | 矩形选择 |
| `markdown_tables` | Markdown 表格渲染 |
| `settings_file` | 本地设置文件持久化 |

**未启用的 feature**: `cloud`, `ai`, `agent_view`, `warp_drive`, `billing` 等云端/AI 模块。

---

## 3. 代码修改清单

共修改 **7 个源文件**，改动极小（约 30 行），均为条件禁用或过滤，不删除任何模块代码。

### 3.1 移除 Sign up 按钮和 Warp AI 按钮

**文件**: `app/src/workspace/view.rs`

```diff
- Container::new(self.render_anonymous_sign_up_user_button(appearance))
+ Container::new(Empty::new().finish()) // Sign up 已禁用
```

```diff
- if is_online {
+ if false // is_online {  // AI 按钮已禁用
```

### 3.2 左侧工具栏只保留 Project Explorer

**文件**: `app/src/workspace/view/left_panel.rs`

两处修改 — 构造函数和 `update_available_views()` 都添加过滤：

```diff
- let active_view = views.first().copied().unwrap_or(ToolPanelView::WarpDrive);
- let toolbelt_buttons = views.iter().map(|view| Self::create_toolbelt_button_config(view, ctx)).collect();
+ let active_view = ToolPanelView::ProjectExplorer;
+ let filtered_views: Vec<ToolPanelView> = views.iter().filter(|v| matches!(v, ToolPanelView::ProjectExplorer)).copied().collect();
+ let toolbelt_buttons = filtered_views.iter().map(|view| Self::create_toolbelt_button_config(view, ctx)).collect();
```

**原理**: `matches!` 宏过滤枚举变体，只有 `ProjectExplorer` 通过。WarpDrive、GlobalSearch、ConversationListView 全部被过滤。

### 3.3 移除输入框底部 Agent 相关 UI

**文件**: `app/src/terminal/input.rs`

禁用 Agent footer 和 Agent input 的条件入口（死代码路径，但保持一致性）：

```diff
- if FeatureFlag::CloudMode.is_enabled() && should_show_status_footer {
+ if false && should_show_status_footer { // Agent footer 已禁用
- } else if FeatureFlag::AgentView.is_enabled()
+ } else if false // Agent input 已禁用
      && self.agent_view_controller.as_ref(app).is_active()
  {
-     self.render_agent_input(app)
+     Empty::new().finish()
```

**关键**: 实际渲染路径是 `render_universal_developer_input()`，见下一项。

**文件**: `app/src/terminal/input/universal.rs`

这才是真正的 Agent UI 渲染入口：

```diff
  use warpui::elements::{
-     Border, ChildView, Container, CornerRadius, DropTarget, Element, Flex, Hoverable,
+     Border, ChildView, Container, CornerRadius, DropTarget, Element, Empty, Flex, Hoverable,
```

```diff
- column.add_child(ChildView::new(&self.universal_developer_input_button_bar).finish());
+ column.add_child(Empty::new().finish()); // Agent button bar 已禁用
```

移除 credits 横幅：

```diff
- maybe_add_buy_credits_banner(
-     &mut stack,
-     &self.buy_credits_banner,
-     self.is_pane_focused(app),
-     self.terminal_view_id,
-     self.is_input_at_top(&model, app),
-     app,
- );
+ // Buy credits banner 已禁用
```

### 3.4 设置界面修改

**文件**: `app/src/settings_view/mod.rs`

三处修改：

1. 注释掉 Agents umbrella 导航（移除整个 Agents 设置页及其 MCP 子页面）：

```diff
  let mut nav_items = vec![
-     SettingsNavItem::Umbrella(SettingsUmbrella::new(
-         "Agents",
-         SettingsSection::ai_subpages().to_vec(),
-     )),
+     // Agents 已禁用
```

2. Code umbrella 中移除 CodeIndexing，只保留 EditorAndCodeReview：

```diff
  SettingsNavItem::Umbrella(SettingsUmbrella::new(
      "Code",
      vec![
-         SettingsSection::CodeIndexing,
+         // SettingsSection::CodeIndexing, // Indexing 已禁用
          SettingsSection::EditorAndCodeReview,
      ],
  )),
```

3. Code 默认子页面改为 EditorAndCodeReview（两处）：

```diff
- Some(SettingsSection::Code) => SettingsSection::CodeIndexing,
+ Some(SettingsSection::Code) => SettingsSection::EditorAndCodeReview,
```

```diff
- SettingsSection::Code => SettingsSection::CodeIndexing,
+ SettingsSection::Code => SettingsSection::EditorAndCodeReview,
```

4. 默认打开 About 页面（`#[default]` 属性）：

```rust
pub enum SettingsSection {
    #[default]
    About,  // 原为 Account
    ...
}
```

**文件**: `app/src/settings_view/teams_page.rs`

```diff
- fn should_render(&self, _ctx: &ViewContext<Self>) -> bool { true }
+ fn should_render(&self, _ctx: &ViewContext<Self>) -> false } // Teams 已禁用
```


### 3.5 移除首次启动登录弹窗

**文件**: `app/src/root_view.rs`

首次打开应用时，未登录用户会看到登录弹窗（AuthOnboardingState::Auth）。将未登录分支也直接进入终端：

```diff
  let auth_onboarding_state = if auth_state.is_logged_in() {
      AuthOnboardingState::Terminal(workspace_args.create_workspace(ctx))
- } else {
-     cfg_if! { ... }
- }
+ } else {
+     // Warple: 未登录时直接进入终端，不显示登录弹窗
+     AuthOnboardingState::Terminal(workspace_args.create_workspace(ctx))
+ };
```

**原理**: `RootView::new()` 中 `auth_onboarding_state` 决定初始界面。原逻辑在未登录时走 FeatureFlag 分支，最终默认到 `Auth`（登录弹窗）。修改后无论登录状态都直接进入 Terminal。
---

## 4. 修改文件汇总

| 文件 | 修改内容 |
|------|----------|
| `app/src/workspace/view.rs` | 移除 Sign up 按钮、AI 按钮 |
| `app/src/workspace/view/left_panel.rs` | 工具栏过滤，只保留 ProjectExplorer |
| `app/src/terminal/input.rs` | 禁用 Agent footer/input 条件 |
| `app/src/terminal/input/universal.rs` | 移除 Agent button bar、credits banner |
| `app/src/settings_view/mod.rs` | 移除 Agents/CodeIndexing 导航，默认 About |
| `app/src/root_view.rs` | 未登录时跳过登录弹窗，直接进入终端 |
| `app/src/settings_view/teams_page.rs` | 隐藏 Teams 页面 |

**总计**: 8 个文件，约 35 行修改。

---

## 5. 打包为 macOS 应用

```bash
bash script/package-warple.sh
```

该脚本会：
1. 将 `target/release/warp-oss` 复制到 `Warple.app/Contents/MacOS/Warple`
2. 从 `app/channels/oss/icon/` 生成 `.icns` 图标
3. 生成 `Info.plist`（Bundle ID: `dev.warp.Warple`）
4. 打包为 DMG 安装镜像

**输出**:
- `dist/Warple.app` — macOS 应用（349MB）
- `dist/Warple.dmg` — DMG 安装镜像（136MB）

---

## 6. 安装与使用

1. 双击 `Warple.dmg`
2. 将 Warple 拖入 Applications
3. 首次打开需右键 → 打开（绕过 Gatekeeper）

**启动后体验**:
- 无登录提示
- 左侧工具栏只有 Project Explorer
- 输入框干净，无 Agent 相关 UI
- 设置默认打开 About 页面
- 无 Agents / CodeIndexing / Teams 设置项
- 完全本地运行，无需网络

---

## 7. 重新编译（修改代码后）

```bash
# 编译
cargo build --release --bin warp-oss \
  --no-default-features \
  --features "release_bundle,gui,local_tty,local_fs,shell_selector,ligatures,rect_selection,markdown_tables,settings_file"

# 打包
bash script/package-warple.sh
```

---

## 8. 注意事项

- 修改策略为**条件禁用**（`if false`、`matches!` 过滤），不删除任何模块代码，便于后续合并上游更新
- `--no-default-features` 排除了大部分云端功能，但部分符号仍因 Rust 静态链接保留在二进制中
- 编译时间约 7-10 分钟（Apple M4 Pro，首次约 40 分钟）
- 图标使用 OSS 渠道的 512x512 PNG，通过 `sips` + `iconutil` 转换为 `.icns`
