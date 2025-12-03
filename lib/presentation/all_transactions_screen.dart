import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mt_my_ledger/bloc/transaction_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_state.dart';
import 'package:mt_my_ledger/models/transaction.dart';
import 'package:mt_my_ledger/presentation/widgets/transaction_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen>
    with TickerProviderStateMixin {
  late AnimationController? animationController;
  late Animation<double>? animation;
  late int _selectedMonth;
  late int _selectedYear;
  double? spendingLimit;
  final numberFormat = NumberFormat('#,##0.00', 'th_TH');

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
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  Future<void> _loadSpendingLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      spendingLimit = prefs.getDouble('spending_limit');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทั้งหมด'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<int>(
              value: _selectedMonth,
              items: List.generate(12, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(
                    DateFormat.MMMM('th_TH').format(DateTime(0, index + 1)),
                  ),
                );
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMonth = newValue;
                  });
                }
              },
              underline: Container(),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            final transactions = state.transactions
                .where(
                  (t) =>
                      t.date.month == _selectedMonth &&
                      t.date.year == _selectedYear,
                )
                .toList();

            transactions.sort((a, b) => b.date.compareTo(a.date));

            if (transactions.isEmpty) {
              return Center(
                child: Text(
                  'ยังไม่มีบันทึกค่าใช้จ่ายในเดือน ${DateFormat.MMMM('th_TH').format(DateTime(0, _selectedMonth))}',
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildMontlySummaryCard(transactions: transactions),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final bool showDateHeader =
                          index == 0 ||
                          transaction.date.day !=
                              transactions[index - 1].date.day;

                      final double? totalAmount = showDateHeader
                          ? transactions
                                .where(
                                  (t) => t.date.day == transaction.date.day,
                                )
                                .fold<double>(
                                  0.0,
                                  (sum, t) =>
                                      sum +
                                      (t.isExpense ? -t.amount : t.amount),
                                )
                          : null;

                      return TransactionListItem(
                        transaction: transaction,
                        showDateHeader: showDateHeader,
                        totalAmount: totalAmount,
                      );
                    },
                  ),
                  SizedBox(height: 100),
                ],
              ),
            );
          } else if (state is TransactionError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('ไม่มีรายการค่าใช้จ่าย'));
          }
        },
      ),
    );
  }

  Widget _buildMontlySummaryCard({required List<Transaction> transactions}) {
    final totalAmount = transactions.fold<double>(
      0.0,
      (sum, transaction) =>
          sum +
          (transaction.isExpense ? -transaction.amount : transaction.amount),
    );

    // calculate amount per day
    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final daysWithTransactions = transactions
        .map((t) => t.date.day)
        .toSet()
        .length;
    final averageDailyExpense = daysWithTransactions > 0
        ? totalExpense / daysWithTransactions
        : 0.0;

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        Card(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          color: Theme.of(context).colorScheme.onSecondary,
          shadowColor: Theme.of(context).colorScheme.shadow.withAlpha(48),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.primary,
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xFFc71585), Color(0xFF4A0000)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'ยอดรวมเดือน ${DateFormat.MMMM('th_TH').format(DateTime(0, _selectedMonth))}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryFixedDim,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
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
                  if (spendingLimit != null && averageDailyExpense > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'เฉลี่ยวันละ ',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryFixedDim,
                            fontSize: 14,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: animation!,
                          builder: (context, child) {
                            return Text(
                              '${numberFormat.format(averageDailyExpense * animation!.value)} ฿',
                              style: TextStyle(
                                color: averageDailyExpense > spendingLimit!
                                    ? Color(0xFFF49097)
                                    : Color(0xFF55D6C2),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Lottie.asset('assets/images/moolah_lottie.json', height: 120),
        ),
      ],
    );
  }
}
