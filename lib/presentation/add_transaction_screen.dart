import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mt_my_ledger/bloc/category_bloc.dart';
import 'package:mt_my_ledger/bloc/category_state.dart';
import 'package:mt_my_ledger/bloc/transaction_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_event.dart';
import 'package:mt_my_ledger/generated/locale_keys.g.dart';
import 'package:mt_my_ledger/models/transaction.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _category;
  bool _isExpense = true;
  late DateTime _selectedDate;
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _category = transaction.category;
      _isExpense = transaction.isExpense;
      _selectedDate = transaction.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processTextWithGemini() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.please_enter_text.tr())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoryState = context.read<CategoryBloc>().state;
      List<String> categories = [];
      if (categoryState is CategoryLoaded) {
        categories =
            categoryState.categories
                .where((category) => category.isDefault)
                .map((e) => e.name)
                .toList();
      }

      final prompt =
          'Extract the transaction details from the following text and return them as a JSON object with \'title\' (string), \'amount\' (double), \'category\' (string) and \'isExpense\' (boolean). The category should be one of: ${categories.join(', ')}. If a category is not explicitly mentioned or cannot be inferred, use \'Other\'.\n\nText: ${_textController.text}';

      final response = await Gemini.instance.prompt(parts: [Part.text(prompt)]);

      if (response != null && response.output != null) {
        final textResponse = response.output;
        final jsonString = textResponse
            ?.replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        if (jsonString != null && jsonString.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(jsonString);

          final title = data['title'] as String?;
          final amount = data['amount'] as double?;
          final category = data['category'] as String?;
          final isExpense = data['isExpense'] as bool?;

          if (title != null && amount != null && category != null) {
            final transaction = Transaction(
              id: const Uuid().v4(),
              title: title,
              amount: amount,
              date: DateTime.now(),
              category: category,
              isExpense: isExpense ?? true,
            );
            if (!context.mounted) return;
            context.read<TransactionBloc>().add(AddTransaction(transaction));
            _textController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocaleKeys.transaction_added.tr())),
            );
            Navigator.pop(context);
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocaleKeys.failed_to_parse_gemini.tr())),
            );
          }
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleKeys.gemini_empty_json.tr())),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.gemini_empty_response.tr())),
        );
      }
    } catch (e) {
      print(e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.error_processing_text.tr(args: [e.toString()]),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    LocaleKeys.date_label.tr(
                      args: [DateFormat.yMMMd(context.locale.toString()).format(_selectedDate)],
                    ),
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.title.tr(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.please_enter_title.tr();
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.amount.tr(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.please_enter_amount.tr();
                    }
                    if (double.tryParse(value) == null) {
                      return LocaleKeys.please_enter_valid_number.tr();
                    }
                    return null;
                  },
                ),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      if (_category == null && state.categories.isNotEmpty) {
                        _category = state.categories.first.name;
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: _category,
                        items: state.categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.name,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _category = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: LocaleKeys.category.tr(),
                        ),
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                SwitchListTile(
                  title: Text(LocaleKeys.expense.tr()),
                  value: _isExpense,
                  onChanged: (value) {
                    setState(() {
                      _isExpense = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newTransaction = Transaction(
                        id: widget.transaction?.id ?? const Uuid().v4(),
                        title: _titleController.text,
                        amount: double.parse(_amountController.text),
                        date: _selectedDate,
                        category: _category!,
                        isExpense: _isExpense,
                      );
                      if (widget.transaction == null) {
                        context.read<TransactionBloc>().add(
                          AddTransaction(newTransaction),
                        );
                      } else {
                        context.read<TransactionBloc>().add(
                          UpdateTransaction(newTransaction),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.transaction == null
                        ? LocaleKeys.add.tr()
                        : LocaleKeys.update.tr(),
                  ),
                ),
                if (widget.transaction == null) const SizedBox(height: 20),
                if (widget.transaction == null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.enter_transaction_details_hint
                                  .tr(),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _processTextWithGemini,
                                child: Text(LocaleKeys.process.tr()),
                              ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
