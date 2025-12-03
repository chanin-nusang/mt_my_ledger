import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mt_my_ledger/bloc/category_bloc.dart';
import 'package:mt_my_ledger/bloc/category_event.dart';
import 'package:mt_my_ledger/bloc/category_state.dart';
import 'package:mt_my_ledger/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หมวดหมู่'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context),
          ),
        ],
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
            return const Center(child: Text('No categories yet.'));
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
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
