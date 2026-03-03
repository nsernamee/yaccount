# YAccount 项目启动指南

## 前置条件

### 1. 安装 Flutter SDK

#### Windows
1. 下载 Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. 解压到某个目录，例如：`C:\flutter`
3. 将 Flutter bin 目录添加到系统环境变量：
   - 右键"此电脑" → 属性 → 高级系统设置 → 环境变量
   - 在"系统变量"中找到 `Path`，点击"编辑"
   - 添加 `C:\flutter\bin`

4. 验证安装：
   ```powershell
   flutter --version
   ```

#### macOS
```bash
brew install --cask flutter
flutter --version
```

### 2. 安装开发工具

#### Android（推荐）
1. 下载 Android Studio: https://developer.android.com/studio
2. 安装 Flutter 和 Dart 插件：
   - File → Settings → Plugins
   - 搜索并安装 "Flutter" 和 "Dart"

3. 创建 Android 模拟器：
   - Tools → Device Manager → Create Device
   - 选择设备型号（推荐 Pixel 5）
   - 下载系统镜像（Android 10 或更高版本）

#### iOS（仅 macOS）
1. 安装 Xcode（从 App Store）
2. 安装 CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```
3. 配置 iOS 模拟器：
   ```bash
   open -a Simulator
   ```

### 3. 验证环境

```powershell
# 检查 Flutter 环境
flutter doctor

# 应该看到以下内容打勾：
# ✓ Flutter
# ✓ Android toolchain
# ✓ VS Code / Android Studio
# ✓ Connected device
```

---

## 启动项目

### 方法一：使用命令行

```powershell
# 1. 进入项目目录
cd d:\repository\yaccount

# 2. 安装依赖
flutter pub get

# 3. 检查是否有设备连接
flutter devices

# 4. 运行应用
# 如果有多个设备，指定设备
flutter run -d <device_id>

# 或者直接运行（会自动选择可用设备）
flutter run
```

### 方法二：使用 Android Studio

1. 打开 Android Studio
2. 点击 `File` → `Open`
3. 选择 `d:\repository\yaccount` 目录
4. 等待项目索引完成
5. 选择目标设备（顶部工具栏）
6. 点击绿色运行按钮 ▶️

### 方法三：使用 VS Code

1. 安装 Flutter 扩展
2. 打开 VS Code
3. `File` → `Open Folder` → 选择 `d:\repository\yaccount`
4. 按 `F5` 或点击 `Run` → `Start Debugging`

---

## 常见问题解决

### 问题1：flutter 命令未找到

**解决方案**：
1. 确认 Flutter SDK 已正确安装
2. 添加到系统环境变量（见前置条件）
3. 重启命令行窗口

### 问题2：依赖安装失败

**解决方案**：
```powershell
# 清理缓存
flutter clean
flutter pub cache repair

# 重新安装依赖
flutter pub get
```

### 问题3：没有可用设备

**解决方案**：

#### Android
1. 打开 Android Studio
2. Tools → Device Manager
3. 创建或启动模拟器
4. 或者连接真实 Android 设备（需开启 USB 调试）

#### iOS（仅 macOS）
1. 打开 Xcode
2. Open Developer Tool → Simulator
3. 选择或创建 iOS 模拟器

#### 连接真实设备

Android 设备：
1. 在手机上开启"开发者选项"
2. 开启"USB 调试"
3. 用 USB 连接电脑
4. 手机上允许 USB 调试

iOS 设备：
1. 用数据线连接 Mac
2. 在 Xcode 中信任设备
3. 在 Xcode 中选择设备作为运行目标

### 问题4：Gradle 构建失败

**解决方案**：
```powershell
# 清理 Android 构建缓存
cd android
gradlew clean
cd ..

# 重新构建
flutter clean
flutter run
```

### 问题5：CocoaPods 安装失败（iOS）

**解决方案**：
```bash
# 进入 iOS 目录
cd ios

# 删除并重新安装 Pods
rm -rf Pods Podfile.lock
pod install

cd ..
```

---

## 快速测试（无需完整环境）

如果你想快速测试 UI 而无需配置完整环境：

### 1. 使用 Flutter Web
```powershell
cd d:\repository\yaccount
flutter pub get
flutter run -d chrome
```

### 2. 使用 Flutter Desktop（Windows/macOS/Linux）
```powershell
flutter run -d windows
# 或
flutter run -d macos
# 或
flutter run -d linux
```

---

## 项目首次运行说明

首次运行时，应用会：

1. **显示启动页**（SplashPage）
   - 初始化数据库（约 1-2 秒）
   - 加载应用设置

2. **进入主页**
   - 显示今日/本周/本月统计
   - 可以开始记账

3. **初始状态**
   - 无历史记录
   - 无预算设置
   - 点击右下角 "+" 按钮开始记账

---

## 开发调试

### �重载（Hot Reload）
```powershell
# 应用运行后，修改代码后按
r
# 或者在 VS Code/Android Studio 中按 Ctrl+S
```

### 热重启（Hot Restart）
```powershell
R
# 大改代码时使用
```

### 查看 Flutter DevTools
```powershell
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 构建发布版本

### Android APK
```powershell
flutter build apk --release
# 输出位置：build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle
```powershell
flutter build appbundle --release
# 输出位置：build/app/outputs/bundle/release/app-release.aab
```

### iOS
```powershell
flutter build ios --release
# 需要使用 Xcode 打包
```

---

## 下一步

1. ✅ 完成 Flutter SDK 安装
2. ✅ 完成开发工具（Android Studio/Xcode）安装
3. ✅ 创建/连接测试设备
4. ✅ 运行 `flutter doctor` 检查环境
5. ✅ 运行 `flutter pub get` 安装依赖
6. ✅ 运行 `flutter run` 启动应用

---

## 需要帮助？

- Flutter 官方文档: https://flutter.dev/docs
- Flutter 中文社区: https://flutter.cn
- Android Studio 文档: https://developer.android.com/studio
- 项目问题: 在项目仓库提交 Issue
