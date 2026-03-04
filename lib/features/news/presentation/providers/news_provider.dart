import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/news_repository.dart';
import 'package:mobile_project_app/features/news/domain/entities/news_item.dart';

// Selected category for filtering
final newsCategoryProvider = StateProvider<String>((ref) => 'All');

// Public News Feed Provider (with pagination)
final newsFeedProvider = StateNotifierProvider<NewsFeedNotifier, AsyncValue<List<NewsItem>>>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  final category = ref.watch(newsCategoryProvider);
  return NewsFeedNotifier(repository, category);
});

class NewsFeedNotifier extends StateNotifier<AsyncValue<List<NewsItem>>> {
  final NewsRepository _repository;
  final String category;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  NewsFeedNotifier(this._repository, this.category) : super(const AsyncValue.loading()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    try {
      final result = await _repository.getNews(page: _currentPage, category: category);
      _hasMore = result['hasMore'];
      state = AsyncValue.data(result['news']);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _repository.getNews(page: 1, category: category);
      _currentPage = 1;
      _hasMore = result['hasMore'];
      state = AsyncValue.data(result['news']);
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isLoadingMore || state is! AsyncData) return;

    _isLoadingMore = true;
    try {
      _currentPage++;
      final result = await _repository.getNews(page: _currentPage, category: category);
      _hasMore = result['hasMore'];
      
      final currentList = state.asData!.value;
      state = AsyncValue.data([...currentList, ...result['news']]);
    } catch (e) {
      _currentPage--; // Revert page on error
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
}

// Admin News Provider
final adminNewsSearchProvider = StateProvider<String>((ref) => '');

final adminNewsProvider = StateNotifierProvider<AdminNewsNotifier, AsyncValue<List<NewsItem>>>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  final search = ref.watch(adminNewsSearchProvider);
  return AdminNewsNotifier(repository, search);
});

class AdminNewsNotifier extends StateNotifier<AsyncValue<List<NewsItem>>> {
  final NewsRepository _repository;
  final String search;

  AdminNewsNotifier(this._repository, this.search) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getAllNewsForAdmin(search: search.isEmpty ? null : search);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Add actions like delete, togglePublish here for UI
  Future<void> delete(String id) async {
    try {
      await _repository.deleteNews(id);
      fetch();
    } catch (e) {}
  }

  Future<void> togglePublish(String id) async {
    try {
      await _repository.togglePublish(id);
      fetch();
    } catch (e) {}
  }
}
