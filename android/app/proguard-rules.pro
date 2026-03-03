# Flutter混淆规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite相关
-keep class * extends android.database.sqlite.SQLiteOpenHelper { *; }

# Provider相关
-keep class * extends androidx.lifecycle.ViewModel { *; }

# 图表库
-keep class fl_chart.** { *; }

# 加密库
-keep class * extends javax.crypto.** { *; }
