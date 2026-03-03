import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/app_provider.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';
import 'pages/statistics_page.dart';
import 'pages/budget_page.dart';
import 'pages/import_export_page.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: MaterialApp(
        title: '本地记账',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'PingFang SC',
        ),
        home: const SplashPage(),
        routes: {
          '/home': (context) => const MainNavigation(),
          '/history': (context) => const HistoryPage(),
          '/statistics': (context) => const StatisticsPage(),
          '/budget': (context) => const BudgetPage(),
          '/import_export': (context) => const ImportExportPage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}

/// 启动页
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.initialize();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80.w,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              '本地记账',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// 主导航页面
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    StatisticsPage(),
    BudgetPage(),
  ];

  final List<String> _titles = ['首页', '记录', '统计', '预算'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_outlined),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            activeIcon: Icon(Icons.receipt_long_outlined),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            activeIcon: Icon(Icons.bar_chart_outlined),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            activeIcon: Icon(Icons.account_balance_wallet_outlined),
            label: '预算',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/import_export'),
              mini: true,
              child: const Icon(Icons.cloud_upload),
            ),
    );
  }
}
