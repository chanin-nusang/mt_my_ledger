import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mt_my_ledger/bloc/category_event.dart';
import 'package:mt_my_ledger/bloc/category_state.dart';
import 'package:mt_my_ledger/repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc(this._categoryRepository) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      try {
        emit(CategoryLoading());
        await _categoryRepository.ensureDefaultCategories();
        final categories = _categoryRepository.getAllCategories();
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<AddCategory>((event, emit) {
      try {
        _categoryRepository.addCategory(event.category);
        add(LoadCategories());
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<UpdateCategory>((event, emit) {
      try {
        _categoryRepository.updateCategory(event.category);
        add(LoadCategories());
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<DeleteCategory>((event, emit) {
      try {
        _categoryRepository.deleteCategory(event.id);
        add(LoadCategories());
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}
