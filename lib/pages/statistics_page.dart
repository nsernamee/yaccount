import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../models/category_model.dart';

/// 视图模式枚举
enum ViewMode {
  monthly,
  yearly,
}

/// 统计页面
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late DateTime _selectedDate;
  ViewMode _viewMode = ViewMode.monthly;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('统计'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildViewModeSelector(),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildPieChart(),
            const SizedBox(height: 24),
            _buildBarChart(),
            const SizedBox(height: 24),
            _buildLineChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeChip(ViewMode.monthly, '月份视图'),
          ),
          Expanded(
            child: _buildModeChip(ViewMode.yearly, '年份视图'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(ViewMode mode, String label) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _viewMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppConstants.primaryColor : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    if (_viewMode == ViewMode.monthly) {
      return _buildMonthSelector();
    } else {
      return _buildYearSelector();
    }
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, Color(0xFF8B7CF7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
          ),
          Expanded(
            child: Text(
              AppDateUtils.formatMonth(_selectedDate),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _selectedDate.month < DateTime.now().month ||
                    _selectedDate.year < DateTime.now().year
                ? () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    // 此方法不再使用,已删除
    return const SizedBox.shrink();
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, Color(0xFF8B7CF7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _selectedDate.year > 2020
                ? () {
                    setState(() {
                      _selectedDate = DateTime(_selectedDate.year - 1, 1);
                    });
                  }
                : null,
          ),
          Expanded(
            child: Text(
              '${_selectedDate.year}年',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _selectedDate.year < DateTime.now().year
                ? () {
                    setState(() {
                      _selectedDate = DateTime(_selectedDate.year + 1, 1);
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: _viewMode == ViewMode.monthly
          ? DatePickerMode.year
          : DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        if (_viewMode == ViewMode.monthly) {
          _selectedDate = picked!;
        } else {
          _selectedDate = DateTime(picked!.year, 1, 1);
        }
      });
    }
  }

  Widget _buildPieChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '支出分类',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, double>>(
            future: _getCategoryStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('暂无数据')),
                );
              }

              final data = snapshot.data!;
              final total = data.values.fold(0.0, (a, b) => a + b);

              return SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: data.entries.map((entry) {
                            final index = data.keys.toList().indexOf(entry.key);
                            final color = AppConstants.chartColors[
                                index % AppConstants.chartColors.length];
                            return PieChartSectionData(
                              value: entry.value,
                              color: color,
                              radius: 50,
                              title: '${(entry.value / total * 100).toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.entries.map((entry) {
                        final index = data.keys.toList().indexOf(entry.key);
                        final color = AppConstants.chartColors[
                            index % AppConstants.chartColors.length];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getCategoryName(entry.key),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, double>> _getCategoryStats() async {
    final provider = context.read<TransactionProvider>();

    if (_viewMode == ViewMode.monthly) {
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      return await provider.getCategoryStats(
        startDate: startDate,
        endDate: endDate,
        type: 'expense',
      );
    } else {
      // 年度视图：统计全年分类支出
      final startDate = DateTime(_selectedDate.year, 1, 1);
      final endDate = DateTime(_selectedDate.year + 1, 1, 0);
      return await provider.getCategoryStats(
        startDate: startDate,
        endDate: endDate,
        type: 'expense',
      );
    }
  }

  Widget _buildBarChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _viewMode == ViewMode.monthly ? '近6个月收支对比' : '年度12个月收支对比',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getMonthlyStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('暂无数据'));
                }

                final data = snapshot.data!;
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(data),
                    barGroups: data.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: (entry.value['income'] as num).toDouble(),
                            color: AppConstants.incomeColor,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: (entry.value['expense'] as num).toDouble(),
                            color: AppConstants.expenseColor,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= data.length) return const Text('');
                            return Text(
                              '${data[value.toInt()]['month']}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppConstants.incomeColor, label: '收入'),
              const SizedBox(width: 24),
              _LegendItem(color: AppConstants.expenseColor, label: '支出'),
            ],
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double max = 0;
    for (final item in data) {
      final income = (item['income'] as num).toDouble();
      final expense = (item['expense'] as num).toDouble();
      if (income > max) max = income;
      if (expense > max) max = expense;
    }
    return max * 1.2;
  }

  Future<List<Map<String, dynamic>>> _getMonthlyStats() async {
    final provider = context.read<TransactionProvider>();

    if (_viewMode == ViewMode.monthly) {
      // 月度视图：显示近6个月
      return await provider.getMonthlyStats(6);
    } else {
      // 年度视图：显示1-12月
      return await provider.getYearlyStats(_selectedDate.year);
    }
  }

  Widget _buildLineChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _viewMode == ViewMode.monthly ? '本月每日支出趋势' : '年度月度支出趋势',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: FutureBuilder<Map<String, double>>(
              future: _getDailyTrend(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('暂无数据'));
                }

                final data = snapshot.data!;
                final spots = <FlSpot>[];

                if (_viewMode == ViewMode.monthly) {
                  // 月度视图：显示当月每天
                  final daysInMonth = DateTime(
                    _selectedDate.year,
                    _selectedDate.month + 1,
                    0,
                  ).day;
                  for (int i = 1; i <= daysInMonth; i++) {
                    final date =
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}';
                    spots.add(FlSpot(
                      i.toDouble(),
                      data[date] ?? 0,
                    ));
                  }
                } else {
                  // 年度视图：显示12个月的支出
                  for (int i = 1; i <= 12; i++) {
                    final monthKey = '$i月';
                    spots.add(FlSpot(
                      i.toDouble(),
                      data[monthKey] ?? 0,
                    ));
                  }
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getLineMaxY(spots) / 4,
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _viewMode == ViewMode.monthly ? 7 : 2,
                          getTitlesWidget: (value, meta) {
                            if (_viewMode == ViewMode.monthly) {
                              return Text(
                                '${value.toInt()}日',
                                style: const TextStyle(fontSize: 10),
                              );
                            } else {
                              return Text(
                                '${value.toInt()}月',
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: _getLineMaxY(spots),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppConstants.expenseColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppConstants.expenseColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getLineMaxY(List<FlSpot> spots) {
    double max = 0;
    for (final spot in spots) {
      if (spot.y > max) max = spot.y;
    }
    return max > 0 ? max * 1.2 : 1000;
  }

  Future<Map<String, double>> _getDailyTrend() async {
    final provider = context.read<TransactionProvider>();

    if (_viewMode == ViewMode.monthly) {
      // 月度视图：获取当月每日趋势
      return await provider.getDailyTrend(
        year: _selectedDate.year,
        month: _selectedDate.month,
      );
    } else {
      // 年度视图：获取年度月度趋势（12个数据点）
      return await provider.getYearlyMonthlyTrend(_selectedDate.year);
    }
  }

  String _getCategoryName(String categoryId) {
    final categories = {
      'food': '餐饮',
      'transport': '交通',
      'shopping': '购物',
      'entertainment': '娱乐',
      'medical': '医疗',
      'education': '教育',
      'housing': '住房',
      'salary': '工资',
      'investment': '投资',
      'other': '其他',
    };
    return categories[categoryId] ?? '其他';
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
