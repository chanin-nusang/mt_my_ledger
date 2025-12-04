import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mt_my_ledger/bloc/auth/auth_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_state.dart';
import 'package:mt_my_ledger/core/extensions/screen_utils.dart';
import 'package:mt_my_ledger/models/transaction.dart';
import 'package:mt_my_ledger/presentation/widgets/transaction_list_item.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController? animationController;
  late Animation<double>? animation;
  double? spendingLimit;
  final numberFormat = NumberFormat('#,##0.00', 'th_TH');

  final colorList = <Color>[
    Color(0xFFF66D44),
    Color(0xFF64C2A6),
    Color(0xFF2D87BB),
  ];

  @override
  void initState() {
    super.initState();
    _loadSpendingLimit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animationController?.forward();
  }

  Future<void> _loadSpendingLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      spendingLimit = prefs.getDouble('spending_limit');
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายรับรายจ่ายของฉัน'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final photoURL = state.user?.photoURL;
              return Row(
                children: [
                  if (!context.isMobile) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        state.user!.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (photoURL != null)
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photoURL,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                      ),
                    )
                  else
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      radius: 24,
                      child: Icon(Icons.person),
                    ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            final today = DateTime.now();
            final todaysTransactions = state.transactions.where((t) {
              return t.date.year == today.year &&
                  t.date.month == today.month &&
                  t.date.day == today.day;
            }).toList();
            final totalAmount = todaysTransactions.fold<double>(
              0.0,
              (sum, transaction) =>
                  sum +
                  (transaction.isExpense
                      ? -transaction.amount
                      : transaction.amount),
            );

            if (todaysTransactions.isEmpty) {
              return Column(
                children: [
                  _buildTodaySummaryCard(
                    todaysTransactions: todaysTransactions,
                    totalAmount: totalAmount,
                    today: today,
                  ),
                  const Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                    child: Text('กด + เพื่อเพิ่มรายการใช้จ่าย'),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodaySummaryCard(
                    todaysTransactions: todaysTransactions,
                    totalAmount: totalAmount,
                    today: today,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'ค่าใช้จ่ายวันนี้',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todaysTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = todaysTransactions[index];
                      return TransactionListItem(transaction: transaction);
                    },
                  ),
                  SizedBox(height: 100),
                ],
              ),
            );
          } else if (state is TransactionError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No transactions yet.'));
          }
        },
      ),
    );
  }

  Widget _buildTodaySummaryCard({
    required List<Transaction> todaysTransactions,
    required double totalAmount,
    required DateTime today,
  }) {
    final categoryTotalAmountDataMap = <String, double>{};

    //Map transactions to categories
    for (var transaction in todaysTransactions) {
      if (categoryTotalAmountDataMap.containsKey(transaction.category)) {
        categoryTotalAmountDataMap[transaction.category] =
            categoryTotalAmountDataMap[transaction.category]! +
            transaction.amount;
      } else {
        categoryTotalAmountDataMap[transaction.category] = transaction.amount;
      }
    }
    final sortedCategories = categoryTotalAmountDataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top2Categories = sortedCategories.take(2).toList();
    final otherCategories = sortedCategories.skip(2).toList();

    final pieChartDataMap = <String, double>{};
    final legendData = <Map<String, dynamic>>[];

    for (var i = 0; i < top2Categories.length; i++) {
      pieChartDataMap[top2Categories[i].key] = top2Categories[i].value;
      legendData.add({
        'color': colorList[i],
        'name': top2Categories[i].key,
        'percent': (top2Categories[i].value / totalAmount.abs()) * 100,
      });
    }

    if (otherCategories.isNotEmpty) {
      final otherAmount = otherCategories.fold<double>(
        0.0,
        (sum, item) => sum + item.value,
      );
      pieChartDataMap['อื่น ๆ'] = otherAmount;
      legendData.add({
        'color': colorList[2],
        'name': 'อื่น ๆ',
        'percent': (otherAmount / totalAmount.abs()) * 100,
      });
    }
    final totalAmountBySpendingLimitPercentage =
        (totalAmount / (spendingLimit ?? 0)).abs() * 100;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.onSecondary,
      shadowColor: Theme.of(context).colorScheme.shadow.withAlpha(48),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.primary,
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Theme.of(context).colorScheme.onSecondaryFixed,
                  Theme.of(context).colorScheme.onPrimaryFixedVariant,
                ],
              ),
            ),
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Lottie.asset(
                  'assets/images/wallet_coins_lottie.json',
                  height: 120,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'ยอดรวมวันนี้',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryFixedDim,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat.yMMMd('th_TH').format(today),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryFixedDim,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: animation!,
                            builder: (context, child) {
                              return Text(
                                '${numberFormat.format(totalAmount.abs() * animation!.value)} ฿',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          if (spendingLimit != null)
                            Text(
                              ' / ${numberFormat.format(spendingLimit!)} ฿',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryFixedDim,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 0),
                      if (todaysTransactions.isNotEmpty)
                        AnimatedBuilder(
                          animation: animation!,
                          builder: (context, child) {
                            return Text(
                              'จำนวน ${(todaysTransactions.length * animation!.value).toStringAsFixed(0)} รายการ',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryFixedDim,
                                fontSize: 14,
                              ),
                            );
                          },
                        )
                      else
                        Text(
                          'ยังไม่มีรายการใช้จ่ายวันนี้',

                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryFixedDim,
                            fontSize: 14,
                          ),
                        ),

                      SizedBox(height: 8),
                      if (spendingLimit != null)
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: animation!,
                              builder: (context, child) {
                                return Text(
                                  '${(totalAmountBySpendingLimitPercentage * animation!.value).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color:
                                        totalAmountBySpendingLimitPercentage >
                                            100
                                        ? Color(0xFFF49097)
                                        : Color(0xFF55D6C2),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),

                            Text(
                              ' ของงบฯ ที่จำกัดไว้',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryFixedDim,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (todaysTransactions.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    height: 50,
                    child: PieChart(
                      dataMap: pieChartDataMap,
                      chartType: ChartType.ring,
                      initialAngleInDegree: -90,
                      baseChartColor: Theme.of(
                        context,
                      ).colorScheme.secondaryFixed,
                      ringStrokeWidth: 8.0,
                      colorList: colorList,
                      chartValuesOptions: ChartValuesOptions(
                        showChartValues: false,
                      ),
                      legendOptions: LegendOptions(showLegends: false),
                      totalValue: totalAmount.abs(),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: legendData.map((data) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 16.0),
                            Column(
                              children: [
                                SizedBox(height: 4),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: data['color'],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data['percent'].toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  data['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
