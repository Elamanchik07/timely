import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../news/domain/entities/news_item.dart';
import '../../../news/presentation/providers/news_provider.dart';
import 'admin_news_editor.dart';

class AdminNewsList extends ConsumerStatefulWidget {
  const AdminNewsList({super.key});

  @override
  ConsumerState<AdminNewsList> createState() => _AdminNewsListState();
}

class _AdminNewsListState extends ConsumerState<AdminNewsList> {
  int _selectedTab = 0; // 0: Published, 1: Drafts

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(adminNewsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminNewsEditor()),
          ).then((_) => ref.invalidate(adminNewsProvider));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новость', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Segmented Control for Drafts/Published
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppTheme.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Опубликованные',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 0 ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppTheme.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Черновики',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 1 ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: newsAsync.when(
              data: (allNews) {
                final news = allNews.where((n) {
                  if (_selectedTab == 0) return n.isPublished;
                  return !n.isPublished;
                }).toList();
                
                if (news.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.newspaper_rounded, size: 36, color: AppTheme.accent),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Новостей пока нет',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Нажмите "+" чтобы создать первую новость',
                    style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7)),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminNewsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              itemCount: news.length,
              itemBuilder: (context, index) {
                final item = news[index];
                return _AdminNewsCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminNewsEditor(news: item)),
                    ).then((_) => ref.invalidate(adminNewsProvider));
                  },
                  onTogglePublish: () =>
                      ref.read(adminNewsProvider.notifier).togglePublish(item.id),
                  onDelete: () => _confirmDelete(context, ref, item),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor.withOpacity(0.7)),
              const SizedBox(height: 12),
              Text('Ошибка: $e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(adminNewsProvider.notifier).fetch(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, NewsItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить новость?'),
        content: Text('Вы уверены, что хотите удалить "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminNewsProvider.notifier).delete(item.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

/// Modern admin news card with status chip and actions.
class _AdminNewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  const _AdminNewsCard({
    required this.item,
    required this.onTap,
    required this.onTogglePublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Media icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.mediaType == 'image'
                        ? Icons.image_outlined
                        : item.mediaType == 'video'
                            ? Icons.videocam_outlined
                            : Icons.article_outlined,
                    color: AppTheme.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Status chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.isPublished
                                  ? AppTheme.successColor.withOpacity(0.15)
                                  : AppTheme.warningColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.isPublished ? 'Опубликовано' : 'Черновик',
                              style: TextStyle(
                                color: item.isPublished ? AppTheme.successColor : AppTheme.warningColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            TimeUtils.relativeTime(item.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIcon(
                      icon: item.isPublished ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: item.isPublished ? AppTheme.textSecondary : AppTheme.successColor,
                      onTap: onTogglePublish,
                    ),
                    const SizedBox(height: 4),
                    _ActionIcon(
                      icon: Icons.delete_outline_rounded,
                      color: AppTheme.errorColor.withOpacity(0.7),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
