import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../providers/news_provider.dart';
import '../widgets/news_item_card.dart';
import 'news_details_screen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/providers/locale_provider.dart';
import 'news_details_screen.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsFeedProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsFeedProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppTheme.backgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 64,
              title: Row(
                children: [
                  // Logo icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accent, Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Timely',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      letterSpacing: 0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.dividerColor.withOpacity(0.5),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildCategorySelector(ref, l10n),
            ),
          ];
        },
        body: newsAsync.when(
          data: (news) {
            if (news.isEmpty) {
              return _buildEmptyState(l10n);
            }

            return RefreshIndicator(
              onRefresh: () async {
                try {
                  await ref.read(newsFeedProvider.notifier).refresh();
                } catch (e) {
                  if (context.mounted) {
                    AppToast.error(context, l10n.failedToLoad);
                  }
                }
              },
              color: AppTheme.accent,
              backgroundColor: AppTheme.surfaceColor,
              displacement: 20,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: news.length +
                    (ref.watch(newsFeedProvider.notifier).hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == news.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    );
                  }
                  final item = news[index];
                  return NewsItemCard(
                    item: item,
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              NewsDetailsScreen(news: item),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.03),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                )),
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => _buildSkeletonLoading(),
          error: (e, st) => _buildErrorState(e, l10n),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: 4,
      itemBuilder: (_, __) => const NewsCardSkeleton(),
    );
  }

  Widget _buildEmptyState(l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.newspaper_rounded,
              size: 40,
              color: AppTheme.accent.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noNews,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.newsWillAppear,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () =>
                ref.read(newsFeedProvider.notifier).fetchInitial(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object e, l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: AppTheme.errorColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.failedToLoad,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.checkConnection,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(newsFeedProvider.notifier).fetchInitial(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(WidgetRef ref, l10n) {
    final categories = ['All', 'Academic', 'Announcements', 'Events', 'Urgent'];
    final selectedCategory = ref.watch(newsCategoryProvider);
    
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              ref.read(newsCategoryProvider.notifier).state = cat;
              ref.read(newsFeedProvider.notifier).fetchInitial();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.accent : AppTheme.dividerColor.withOpacity(0.5),
                ),
              ),
              child: Text(
                l10n.newsCategory(cat),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
