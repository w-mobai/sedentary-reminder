# Move Ease

一款原生 macOS 久坐提醒应用。专注倒计时结束后，会发送系统通知并显示无法忽略的全屏活动提醒，帮助你真正离开屏幕、起身活动。

## 下载与安装

从 [GitHub Releases](https://github.com/w-mobai/sedentary-reminder/releases/latest) 下载最新的 `Move-Ease-macOS-arm64.dmg`：

1. 打开 DMG。
2. 将 Move Ease 拖入 Applications。
3. 从“应用程序”文件夹启动。

当前版本使用本地签名，首次运行若被 macOS 拦截，请在 Finder 中右键应用并选择“打开”。

## 功能

- 菜单栏实时倒计时
- 可调节 20–90 分钟专注时长与 2–15 分钟活动时长
- 暂停、继续、重新开始与稍后提醒
- 覆盖所有屏幕的强制休息遮罩
- 提醒卡片内活动倒计时
- 3 秒快速测试模式
- macOS 系统通知与声音开关
- 本地保存个人设置

## 系统要求

- Apple Silicon Mac（M1、M2、M3、M4 或更新型号）
- macOS 14 Sonoma 或更高版本

## 构建与运行

开发环境需要完整安装的 Xcode 16（仅 Command Line Tools 不足以构建 SwiftUI 应用）。

```bash
chmod +x scripts/build-app.sh
./scripts/build-app.sh
open "build/Move Ease.app"
```

如果刚安装 Xcode，请先执行 `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`。

首次运行时，请允许系统通知。关闭主窗口后，应用仍会保留在菜单栏中；可从菜单栏再次打开或退出。

## 生成 DMG 安装包

```bash
chmod +x scripts/build-dmg.sh
./scripts/build-dmg.sh
```

生成的安装包位于 `build/Move-Ease-macOS-arm64.dmg`。打开后，将 Move Ease 拖到 Applications 即可安装。

## 隐私

Move Ease 不收集、不上传任何个人数据。计时设置仅保存在本机的 UserDefaults 中。

## 项目结构

```text
Assets/              应用图标源文件
Sources/MoveEase/    SwiftUI 与计时逻辑
scripts/             App 和 DMG 构建脚本
Package.swift        Swift Package 配置
```

## 许可证

本项目使用 [MIT License](LICENSE)。
