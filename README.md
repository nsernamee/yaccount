# YAccount - 智能记账应用

一款安全、隐私的本地记账应用。数据完全存储在本地，保护您的财务隐私。

## 下载安装

### 最新发布版本

**[📱 下载 APK v1.2.0](https://github.com/nsernamee/yaccount/releases/tag/v1.2.0/app-release.apk)**

直接点击上方链接下载安装，支持 Android 5.0+ 系统。

### 安装说明

1. 下载 APK 文件
2. 在手机设置中允许"未知来源"应用安装
3. 打开 APK 文件并安装

---

## 功能特点

### 核心功能
- 📝 **快速记账**：简洁的界面，快速记录收入和支出
- 🏠 **首页仪表盘**：直观查看今日、本周、本月收支概况，负数余额红色显示
- 💰 **预算管理**：支持总预算和分类预算设置，实时预算进度跟踪，百分比显示
- 📊 **数据统计**：饼图、柱状图、折线图多维度展示收支数据
- 📜 **历史记录**：完整的交易历史，支持筛选、分页加载、编辑和删除
- 📤 **数据导入导出**：支持 CSV/Excel 格式导出和导入，分类名称自动映射
- 🌍 **多货币支持**：支持人民币、美元、欧元等多种货币切换，实时更新所有页面显示

### 安全与隐私
- 🔐 **本地存储**：数据完全存储在本地，不联网
- 🔒 **无网络权限**：应用不申请任何网络权限，确保绝对隐私
- 💾 **SQLite 存储**：使用 SQLite 本地数据库，稳定可靠
- 🔐 **数据库加密**：可选 AES-256 加密保护数据安全

### 界面设计
- 🎨 **Material Design**：遵循 Material Design 设计规范
- 🌙 **舒适配色**：精心调配的配色方案
- 📱 **响应式布局**：适配不同屏幕尺寸
- ⚡ **流畅交互**：优化的性能体验

---

## 项目结构

```
yaccount/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   │   ├── transaction_model.dart    # 交易记录模型
│   │   ├── budget_model.dart         # 预算模型
│   │   └── category_model.dart       # 分类模型
│   ├── providers/                # 状态管理
│   │   ├── app_provider.dart         # 应用全局状态
│   │   ├── transaction_provider.dart # 交易数据管理
│   │   └── budget_provider.dart      # 预算数据管理
│   ├── pages/                    # 页面
│   │   ├── home_page.dart            # 首页
│   │   ├── add_transaction_page.dart # 添加交易
│   │   ├── history_page.dart         # 历史记录
│   │   ├── statistics_page.dart      # 统计图表
│   │   ├── budget_page.dart          # 预算管理
│   │   ├── import_export_page.dart   # 导入导出
│   │   └── settings_page.dart        # 设置
│   ├── widgets/                  # 自定义组件
│   │   ├── common_widgets.dart       # 通用组件
│   │   └── category_selector.dart    # 分类选择器
│   ├── database/                 # 数据库
│   │   └── database_helper.dart      # 数据库操作
│   └── utils/                    # 工具类
│       ├── constants.dart             # 常量定义
│       └── date_utils.dart            # 日期工具
├── android/                      # Android 原生代码
├── ios/                          # iOS 原生代码
├── pubspec.yaml                  # 项目配置
└── README.md                     # 项目文档
```

详细的项目结构说明请参考 [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

---

## 技术栈

### 核心技术
- **Flutter 3.x**：跨平台 UI 框架
- **Dart 3.x**：编程语言
- **Provider**：状态管理
- **SQLite**：本地数据库

### 主要依赖
- `sqflite_sqlcipher`：加密数据库支持
- `fl_chart`：图表绘制
- `excel`：Excel 文件处理
- `file_picker`：文件选择
- `flutter_slidable`：滑动操作
- `uuid`：唯一标识符生成
- `path_provider`：文件路径获取

---

## 开发快速开始

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

#### 构建 Android App Bundle

```bash
flutter build appbundle --release
```

---

## 使用指南

### 快速记账

1. 点击首页的"记一笔"按钮
2. 选择收入或支出类型
3. 输入金额
4. 选择分类
5. 可选择添加备注和修改日期
6. 点击保存

### 查看统计

1. 首页显示今日、本周、本月收支汇总
2. 点击底部"统计"查看详细图表
3. 支持饼图、柱状图、折线图切换
4. 可选择不同月份查看

### 设置预算

1. 点击底部"预算"进入预算管理
2. 设置月度总预算
3. 为不同分类设置预算
4. 实时查看预算使用进度和百分比

### 数据管理

1. **导出数据**：进入设置页面，选择导出格式（CSV/Excel）
2. **导入数据**：进入设置页面，选择导入文件，支持增量追加和覆盖替换
3. **清空数据**：谨慎操作，不可恢复

### 货币设置

1. 点击首页右上角货币图标切换货币类型
2. 支持人民币（¥）、美元（$）、欧元（€）等多种货币
3. 切换货币后所有页面自动更新显示

---

## 故障排除

### 常见问题

**应用启动后白屏**
```bash
# 清理缓存重新构建
flutter clean
flutter pub get
flutter run
```

**打包失败**
```bash
# 检查 Flutter 环境
flutter doctor

# 确保 Android SDK 配置正确
```

---

## 版本历史

### v1.2.0 (2026-03-05)
- ✨ 新增多货币支持，支持人民币、美元、欧元等货币切换
- 🎨 优化货币符号显示位置（金额后显示）
- 🔧 修复货币选择实时同步问题
- 🐛 修复 SharedPreferences 连接错误
- 📤 优化数据导出功能，分类名称正确映射
- 🔐 完善数据库加密功能
- 📱 更新设置页面版本显示

### v1.0.0
- 初始版本发布
- 基础记账功能
- 数据统计和预算管理
- 数据导入导出

---

## 开源协议

本项目采用 MIT 开源协议。

---

## 贡献

欢迎提交 Issue 和 Pull Request！

---

**YAccount - 让记账更简单、更安全**
