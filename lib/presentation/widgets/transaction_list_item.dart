import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mt_my_ledger/bloc/transaction_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_event.dart';
import 'package:mt_my_ledger/models/transaction.dart';
import 'package:mt_my_ledger/presentation/add_transaction_screen.dart';

class TransactionListItem extends StatefulWidget {
  final Transaction transaction;
  final bool showDateHeader;
  final double? totalAmount;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.showDateHeader = false,
    this.totalAmount,
  });

  @override
  State<TransactionListItem> createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem> {
  final numberFormat = NumberFormat('#,##0.00', 'th_TH');

  void _removeTransaction(BuildContext context) {
    context.read<TransactionBloc>().add(
      DeleteTransaction(widget.transaction.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDateHeader)
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    DateFormat.yMMMd('th_TH').format(widget.transaction.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Text(
                    widget.totalAmount != null
                        ? '${numberFormat.format(widget.totalAmount!)} ฿'
                        : '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Slidable(
          key: ValueKey(widget.transaction.id),
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: ScrollMotion(),
            children: [
              FilledButton(
                onPressed: () {
                  _removeTransaction(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Icon(Icons.delete),
              ),
            ],
          ),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.onSecondary,
            shadowColor: Theme.of(context).colorScheme.shadow.withAlpha(48),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(widget.transaction.title),
              subtitle: Text(
                widget.transaction.category,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 13,
                ),
              ),
              trailing: Text(
                (widget.transaction.isExpense ? '-' : '+') +
                    ('${numberFormat.format(widget.transaction.amount)} ฿'),
                style: TextStyle(
                  color: widget.transaction.isExpense
                      ? Colors.red
                      : Colors.green,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) =>
                      AddTransactionScreen(transaction: widget.transaction),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
