import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/transaction_provider.dart';
import '../providers/app_provider.dart';

/// 统计页面 - 包含饼图、柱状图、折线图
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends<StatisticsPage> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStatisticsData();
  }

  Future<void> _loadStatisticsData() async {
    final appProvider = context.read<AppProvider>();
    // 数据加载会触发Consumer刷新
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildTabBar(),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (_selectedTabIndex == 0) {
                  return _buildPieChartTab(provider);
                } else if (_selectedTabIndex == 1) {
                  return _buildBarChartTab(provider);
                } else {
                  return _buildLineChartTab(provider);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建月份选择器
  Widget _buildMonthSelector() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => appProvider.previousMonth(),
              ),
              Text(
                '${appProvider.selectedYear}年${appProvider.selectedMonth}月',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => appProvider.nextMonth(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建Tab切换器
  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem('分类占比', 0),
          _buildTabItem('月度对比', 1),
          _BuildTabItem('每日趋势', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建饼图Tab（分类占比）
  Widget _buildPieChartTab(TransactionProvider provider) {
    return FutureBuilder<Map<String, double>>(
      future: provider.getCategoryStatistics(
        'expense',
        context.read<AppProvider>().selectedYear,
        context.read<AppProvider>().selectedMonth,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '暂无数据',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          );
        }

        final data = snapshot.data!;
        final total = data.values.reduce((a, b) => a + b);

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(
                height: 250.h,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieSections(data, total),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              _buildPieLegend(data, total),
            ],
          ),
        );
      },
    );
  }

  /// 构建饼图数据段
  List<PieChartSectionData> _buildPieSections(Map<String, double> data, double total) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    int index = 0;
    return data.entries.map((entry) {
      final value = entry.value;
      final percentage = (value / total * 100).toStringAsFixed(1);
      final color = colors[index % colors.length];

      index++;
      return PieChartSectionData(
        color: color,
        value: value,
        title: '$percentage%',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// 构建饼图图例
  Widget _buildPieLegend(Map<String, double> data, double total) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    int index = 0;
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedData.map((entry) {
        final color = colors[index % colors.length];
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        index++;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  entry.key,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              Text(
                '¥${entry.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 构建柱状图Tab（月度对比）
  Widget _buildBarChartTab(TransactionProvider provider) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getMonthlyComparison(6),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '暂无数据',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          );
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: SizedBox(
            height: 300.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _calculateMaxY(data),
                minY: 0,
                groupsSpace: 12,
                barGroups: _buildBarGroups(data),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => _buildBottomTitle(value, data),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 计算Y轴最大值
  double _calculateMaxY(List<Map<String, dynamic>> data) {
    double maxIncome = 0;
    double maxExpense = 0;

    for (var month in data) {
      maxIncome = maxIncome > (month['income'] as double) ? maxIncome : month['income'];
      maxExpense = maxExpense > (month['expense'] as double) ? maxExpense : month['expense'];
    }

    return ((maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2).ceilToDouble();
  }

  /// 构建柱状图数据组
  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> data) {
    return data.map((month) {
      final index = data.indexOf(month);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: month['income'] as double,
            color: Colors.green,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: month['expense'] as double,
            color: Colors.red,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  /// 构建底部标题
  Widget _buildBottomTitle(double value, List<Map<String, dynamic>> data) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) return const Text('');

    final month = data[index]['month'] as String;
    final parts = month.split('-');
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        '${parts[1]}月',
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// 构建折线图Tab（每日趋势）
  Widget _buildLineChartTab(TransactionProvider provider) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getDailyExpenseTrend(
        context.read<AppProvider>().selectedYear,
        context.read<AppProvider>().selectedMonth,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '暂无数据',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          );
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(
                height: 300.h,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: _calculateLineMaxY(data),
                    lineBarsData: [
                      _buildExpenseLine(data),
                      _buildIncomeLine(data),
                    ],
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey[200],
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (data.length / 7).ceilToDouble(),
                          getTitlesWidget: (value, meta) => _buildLineBottomTitle(value, data),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.white.withOpacity(0.9),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index >= data.length) return null;
                            
                            final day = data[index];
                            final type = spot.barIndex == 0 ? '支出' : '收入';
                            final amount = spot.y;
                            
                            return LineTooltipItem(
                              '$type\n¥${amount.toStringAsFixed(2)}',
                              TextStyle(
                                color: spot.barIndex == 0 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              _buildLineChartLegend(),
            ],
          ),
        );
      },
    );
  }

  /// 计算折线图Y轴最大值
  double _calculateLineMaxY(List<Map<String, dynamic>> data) {
    double maxY = 0;

    for (var day in data) {
      final expense = day['expense'] as double;
      final income = day['income'] as double;
      final maxDay = expense > income ? expense : income;
      maxY = maxY > maxDay ? maxY : maxDay;
    }

    return (maxY * 1.2).ceilToDouble();
  }

  /// 构建支出折线
  LineChartBarData _buildExpenseLine(List<Map<String, dynamic>> data) {
    return LineChartBarData(
      isCurved: true,
      color: Colors.red,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.red.withOpacity(0.1),
      ),
      spots: data.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value['expense'] as double,
        );
      }).toList(),
    );
  }

  /// 构建收入折线
  LineChartBarData _buildIncomeLine(List<Map<String, dynamic>> data) {
    return LineChartBarData(
      isCurved: true,
      color: Colors.green,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.green.withOpacity(0.1),
      ),
      spots: data.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value['income'] as double,
        );
      }).toList(),
    );
  }

  /// 构建折线图底部标题
  Widget _buildLineBottomTitle(double value, List<Map<String, dynamic>> data) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) return const Text('');

    final dateStr = data[index]['date'] as String;
    final day = int.parse(dateStr.split('-')[2]);

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        '$day日',
        style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
      ),
    );
  }

  /// 构建折线图图例
  Widget _buildLineChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('支出', Colors.red),
        SizedBox(width: 24.w),
        _buildLegendItem('收入', Colors.green),
      ],
    );
  }

  /// 构建图例项
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
    );
  }
}
