# Warple

**Warple** = **Warp** **L**ocal **E**dition

A minimal, offline-first build of [Warp](https://github.com/warpdotdev/warp) terminal — for users who want a clean terminal GUI without cloud services, AI features, or login prompts.

[中文说明](README_CN.md)

---

## About

This project is derived from the [Warp open-source repository](https://github.com/warpdotdev/warp).

**Warple** is designed for users who:
- Want to use Warp's terminal GUI purely locally
- Prefer not to be interrupted by online features
- Have no need for AI capabilities

## What's Removed

| Feature | Status |
|---------|--------|
| Login / Sign up | Disabled |
| Warp AI | Disabled |
| Warp Drive | Disabled |
| Cloud sync | Disabled |
| Billing | Disabled |
| Agent Mode | Disabled |

## What's Kept

- Modern terminal emulator
- GPU-accelerated rendering
- Ligatures support
- Rectangular selection
- Markdown tables rendering
- Local settings persistence
- Shell selector

## Build

See [WARPLE_BUILD_GUIDE.md](WARPLE_BUILD_GUIDE.md) for detailed instructions.

```bash
# Build
cargo build --release --bin warp-oss \
  --no-default-features \
  --features "release_bundle,gui,local_tty,local_fs,shell_selector,ligatures,rect_selection,markdown_tables,settings_file"

# Package (macOS)
bash script/package-warple.sh
```

## Contributing

Bug reports and improvements are welcome! Please open an issue or submit a pull request.

## License

This project inherits the licensing from the upstream Warp repository:
- UI framework (`warpui_core`, `warpui`): MIT License
- Rest of the code: AGPL v3

## Acknowledgments

- [Warp](https://www.warp.dev) — The original terminal that Warple is based on
- All the open-source dependencies that make this possible
