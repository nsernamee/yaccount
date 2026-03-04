# YAccount - AI 赋能的智能记账应用

一款由 AI 辅助开发的安全、隐私的本地记账应用。通过 AI 驱动的开发流程，实现了高效、现代化的用户界面和健壮的功能实现。

## ⬇️ 下载安装

### 最新发布版本

**[📱 下载 APK v1.0.0](https://github.com/nsernamee/yaccount/releases/tag/v1.0.0/app-release.apk)**

直接点击上方链接下载安装，支持 Android 5.0+ 系统（包括 Orange 6 等国产系统）。

### 安装说明

1. 下载 APK 文件
2. 在手机设置中允许"未知来源"应用安装
3. 打开 APK 文件并安装

---

## ✨ AI 赋能特色

本项目采用 AI 辅助开发模式，由智能编程助手全程参与代码实现、优化和调试，具备以下优势：

- 🤖 **智能代码生成**：AI 助手协助生成高质量、可维护的代码
- 🎯 **精准需求实现**：快速将用户需求转化为具体功能
- 🔍 **智能问题诊断**：自动识别并解决编译、构建和运行时问题
- 💡 **最佳实践应用**：AI 自动应用 Flutter 最佳实践和设计模式
- 📚 **文档同步生成**：项目结构与文档由 AI 自动生成并维护

通过 AI 赋能的开发流程，本项目在短时间内完成了从零到完整应用的开发，确保代码质量和用户体验达到专业水准。

## 📱 功能特点

### 核心功能
- 📝 **快速记账**：简洁的界面，快速记录收入和支出
- 🏠 **首页仪表盘**：直观查看今日、本周、本月收支概况
- 💰 **预算管理**：支持总预算和分类预算设置，实时预算进度跟踪
- 📊 **数据统计**：饼图、柱状图、折线图多维度展示收支数据
- 📜 **历史记录**：完整的交易历史，支持筛选、编辑和删除
- 📤 **数据导出**：支持导出为 Excel 格式，方便数据备份和分析

### 安全与隐私
- 🔐 **数据库加密**：可选 AES-256 加密保护您的财务数据
- 📴 **完全本地存储**：不联网、不上传，数据完全在本地
- 🔒 **无网络权限**：应用不申请任何网络权限，确保绝对隐私
- 💾 **SQLite 存储**：使用 SQLite 本地数据库，稳定可靠

### 界面设计
- 🎨 **Material Design**：遵循 Material Design 设计规范，美观现代
- 🌙 **舒适配色**：精心调配的配色方案，长时间使用不疲劳
- 📱 **响应式布局**：适配不同屏幕尺寸的设备
- ⚡ **流畅交互**：优化的性能，丝滑的用户体验

## 🛠️ 开发快速开始

### 环境要求

- Flutter SDK 3.16.0 或更高版本
- Dart 3.2.0 或更高版本
- Android SDK（Android 5.0/API 21 或更高）
- IDE：推荐使用 Android Studio 或 VS Code

### 安装步骤

#### 1. 克隆项目

```bash
git clone <repository-url>
cd yaccount
```

#### 2. 安装依赖

```bash
flutter pub get
```

#### 3. 运行项目

**在模拟器上运行：**
```bash
flutter run
```

**在真实设备上运行：**
```bash
# 确保设备已连接并启用 USB 调试
flutter devices
flutter run
```

### 打包发布

#### 构建 Android APK

```bash
# 构建 release 版本
flutter build apk --release

# APK 文件位置：build/app/outputs/flutter-apk/app-release.apk
```

#### 构建 Android App Bundle（用于应用商店）

```bash
flutter build appbundle --release
```

## 📂 项目结构

```
yaccount/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   │   ├── transaction_model.dart
│   │   ├── budget_model.dart
│   │   └── category_model.dart
│   ├── providers/                # 状态管理
│   │   ├── app_provider.dart
│   │   ├── transaction_provider.dart
│   │   └── budget_provider.dart
│   ├── pages/                    # 页面
│   │   ├── home_page.dart
│   │   ├── stats_page.dart
│   │   ├── budget_page.dart
│   │   ├── history_page.dart
│   │   ├── import_export_page.dart
│   │   └── settings_page.dart
│   ├── widgets/                  # 自定义组件
│   │   ├── common_widgets.dart
│   │   └── category_selector.dart
│   ├── database/                 # 数据库
│   │   └── database_helper.dart
│   └── utils/                    # 工具类
│       ├── constants.dart
│       └── date_utils.dart
├── android/                      # Android 原生代码
├── ios/                          # iOS 原生代码
├── pubspec.yaml                  # 项目配置
└── README.md                     # 项目文档
```

详细的项目结构说明请参考 [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

## 🛠️ 技术栈

### 核心技术
- **Flutter 3.16+**：跨平台 UI 框架
- **Dart 3.2+**：编程语言
- **Provider**：状态管理
- **SQLite**：本地数据库

### 主要依赖
- `sqflite_sqlcipher`：加密数据库支持
- `excel`：Excel 文件导出
- `fl_chart`：图表绘制
- `file_picker`：文件选择
- `flutter_slidable`：滑动操作
- `uuid`：唯一标识符生成

## 📖 使用指南

### 首次使用

1. **快速记账**
   - 点击首页的"记一笔"按钮
   - 选择收入或支出
   - 输入金额、选择分类、添加备注
   - 点击保存

2. **查看统计**
   - 首页显示今日、本周、本月收支汇总
   - 点击"统计分析"查看详细图表
   - 支持按时间范围筛选

3. **设置预算**
   - 点击"预算管理"
   - 设置总预算
   - 为不同分类设置预算
   - 实时查看预算使用进度

4. **数据管理**
   - 导出 Excel：点击首页右上角导出按钮
   - 导入数据：在"数据管理"页面导入 Excel
   - 清空数据：谨慎操作，不可恢复

### 数据安全

1. **启用加密**
   - 进入"设置"页面
   - 开启"数据库加密"
   - 设置密码（至少6位）
   - **重要**：请务必记住密码，忘记将无法恢复数据

2. **备份数据**
   - 定期导出 Excel 文件进行备份
   - 导出的 Excel 文件包含所有交易记录

## 🐛 故障排除

### 常见问题

**Q: 打包时出现 R8 混淆错误**
```bash
# 解决方法：已配置混淆规则，包含 Google Play Core 相关规则
# 位于 android/app/proguard-rules.pro
```

**Q: NDK 版本冲突**
```bash
# 项目已配置 NDK 27.0.12077973
# 位于 android/app/build.gradle.kts
```

**Q: 应用启动崩溃**
```bash
# 运行 flutter doctor 检查环境
flutter doctor

# 清理缓存重新构建
flutter clean
flutter pub get
```

## 📄 开源协议

本项目采用 MIT 开源协议，详情请参阅 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📧 联系方式

如有问题或建议，欢迎通过 Issue 联系我们。

---

**YAccount - 由 AI 赋能，让记账更智能、更安全**
