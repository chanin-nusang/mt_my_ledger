import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mt_my_ledger/bloc/category_bloc.dart';
import 'package:mt_my_ledger/bloc/category_event.dart';
import 'package:mt_my_ledger/bloc/category_state.dart';
import 'package:mt_my_ledger/generated/locale_keys.g.dart';
import 'package:mt_my_ledger/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.category.tr()),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () => _showCategoryDialog(context),
        //   ),
        // ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoryLoaded) {
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: category.isDefault
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showCategoryDialog(
                                context,
                                category: category,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                context.read<CategoryBloc>().add(
                                  DeleteCategory(category.id),
                                );
                              },
                            ),
                          ],
                        ),
                );
              },
            );
          } else if (state is CategoryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text(LocaleKeys.no_categories_yet.tr()));
          }
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final nameController = TextEditingController(text: category?.name);
    final isEditing = category != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEditing
                ? LocaleKeys.edit_category.tr()
                : LocaleKeys.add_category.tr(),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: LocaleKeys.category_name.tr(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  if (isEditing) {
                    final updatedCategory = Category(
                      id: category.id,
                      name: name,
                    );
                    context.read<CategoryBloc>().add(
                      UpdateCategory(updatedCategory),
                    );
                  } else {
                    final newCategory = Category(
                      id: const Uuid().v4(),
                      name: name,
                    );
                    context.read<CategoryBloc>().add(AddCategory(newCategory));
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(
                isEditing ? LocaleKeys.update.tr() : LocaleKeys.add.tr(),
              ),
            ),
          ],
        );
      },
    );
  }
}
