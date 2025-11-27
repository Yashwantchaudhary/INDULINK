import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

/// Category state
class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isEmpty => categories.isEmpty;
  bool get hasCategories => categories.isNotEmpty;
}

/// Category notifier
class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService _categoryService;

  CategoryNotifier(this._categoryService) : super(CategoryState());

  /// Fetch categories
  Future<void> fetchCategories() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _categoryService.getCategories();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh categories
  Future<void> refresh() async {
    state = CategoryState();
    await fetchCategories();
  }
}

/// Category service provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

/// Category provider
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  return CategoryNotifier(categoryService);
});
