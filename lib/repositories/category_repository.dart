import 'package:hive/hive.dart';
import 'package:mt_my_ledger/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final Box<Category> _categoryBox;

  CategoryRepository(this._categoryBox);

  Future<void> addCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
  }

  List<Category> getAllCategories() {
    return _categoryBox.values.toList();
  }

  Future<void> ensureDefaultCategories() async {
    if (_categoryBox.isEmpty) {
      final defaultCategories = [
        Category(id: const Uuid().v4(), name: 'Food', isDefault: true),
        Category(id: const Uuid().v4(), name: 'Transport', isDefault: true),
        Category(id: const Uuid().v4(), name: 'Shopping', isDefault: true),
        Category(id: const Uuid().v4(), name: 'Salary', isDefault: true),
        Category(id: const Uuid().v4(), name: 'Other', isDefault: true),
      ];
      for (var category in defaultCategories) {
        await addCategory(category);
      }
    }
  }
}
