import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart';
import 'package:mt_my_ledger/bloc/category_bloc.dart';
import 'package:mt_my_ledger/bloc/category_state.dart';
import 'package:mt_my_ledger/bloc/transaction_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_event.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter some text.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoryState = context.read<CategoryBloc>().state;
      List<String> categories = [];
      if (categoryState is CategoryLoaded) {
        categories = categoryState.categories
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
            context.read<TransactionBloc>().add(AddTransaction(transaction));
            _textController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction added successfully!')),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to parse Gemini response. Missing data.'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gemini returned empty or invalid JSON.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemini response was empty.')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing text: ${e.toString()}')),
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
                    'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
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
                        value: _category,
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
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                SwitchListTile(
                  title: const Text('Expense'),
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
                  child: Text(widget.transaction == null ? 'Add' : 'Update'),
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
                            decoration: const InputDecoration(
                              hintText:
                                  'Enter transaction details (e.g., ค่าสุกี้ 200 บาท)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _processTextWithGemini,
                                child: const Text('Process'),
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
