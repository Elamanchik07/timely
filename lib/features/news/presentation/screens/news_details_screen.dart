import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/news_repository.dart';
import '../../domain/entities/news_item.dart';

class NewsDetailsScreen extends ConsumerStatefulWidget {
  final NewsItem news;
  const NewsDetailsScreen({super.key, required this.news});

  @override
  ConsumerState<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends ConsumerState<NewsDetailsScreen> {
  Map<String, dynamic> _reactionCounts = {};
  String? _myReaction;
  bool _reactionInProgress = false;

  final Map<String, String> _reactionEmojis = {
    'heart': '❤️',
    'thumbsUp': '👍',
    'fire': '🔥',
    'party': '🎉',
  };

  @override
  void initState() {
    super.initState();
    _reactionCounts = Map<String, dynamic>.from(widget.news.reactionCounts);

    // Track view when opening this screen
    Future.microtask(() {
      ref.read(newsRepositoryProvider).trackView(widget.news.id);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateReactionState(widget.news.reactions);
  }

  void _updateReactionState(List<Map<String, dynamic>> reactions) {
    final user = ref.read(authProvider).asData?.value;
    if (user != null) {
      final myR = reactions.where((r) {
        final userId = r['userId'];
        if (userId is Map) return userId['_id']?.toString() == user.id;
        return userId?.toString() == user.id;
      }).firstOrNull;
      _myReaction = myR?['type'] as String?;
    } else {
      _myReaction = null;
    }
  }

  Future<void> _toggleReaction(String type) async {
    if (_reactionInProgress) return;
    final user = ref.read(authProvider).asData?.value;
    if (user == null) return;

    final oldReaction = _myReaction;
    final oldCounts = Map<String, dynamic>.from(_reactionCounts);

    setState(() {
      _reactionInProgress = true;
      if (_myReaction == type) {
        _myReaction = null;
        _reactionCounts[type] = (_reactionCounts[type] as int? ?? 1) - 1;
      } else {
        if (_myReaction != null) {
          _reactionCounts[_myReaction!] = (_reactionCounts[_myReaction!] as int? ?? 1) - 1;
        }
        _myReaction = type;
        _reactionCounts[type] = (_reactionCounts[type] as int? ?? 0) + 1;
      }
    });
    HapticFeedback.lightImpact();

    try {
      final repo = ref.read(newsRepositoryProvider);
      final result = await repo.toggleReaction(widget.news.id, type);
      if (mounted) {
        setState(() {
          _reactionCounts = result['reactionCounts'];
          _updateReactionState(List<Map<String, dynamic>>.from(result['reactions']));
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _myReaction = oldReaction;
          _reactionCounts = oldCounts;
        });
      }
    } finally {
      if (mounted) setState(() => _reactionInProgress = false);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Urgent':
        return Colors.redAccent;
      case 'Events':
        return Colors.orangeAccent;
      case 'Academic':
        return Colors.blueAccent;
      default:
        return AppTheme.accent;
    }
  }

  void _shareNews(l10n) {
    final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
    final text = '${widget.news.title}\n\n${widget.news.content}';
    final imageInfo = widget.news.mediaPath != null
        ? '\n\n${l10n.mapRoom("").split(":")[0]}: $baseUrl${widget.news.mediaPath}'
        : '';
    Share.share('$text$imageInfo');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
    final imageUrl =
        widget.news.mediaPath != null ? '$baseUrl${widget.news.mediaPath}' : null;
    final authorName = widget.news.author?['fullName'] ?? l10n.adminAuthor;
    final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'T';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: imageUrl != null ? 320 : 0,
            pinned: true,
            backgroundColor: AppTheme.primaryMid,
            surfaceTintColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: imageUrl != null
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppTheme.surfaceColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.accent,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.primaryMid,
                            child: const Icon(Icons.broken_image_outlined,
                                size: 48, color: AppTheme.textSecondary),
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black38, Colors.transparent, Colors.black87],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges (Category & Pinned)
                  Row(
                    children: [
                      if (widget.news.isPinned) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.push_pin_rounded, size: 14, color: AppTheme.accent),
                              const SizedBox(width: 4),
                              Text(l10n.pinned, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.news.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.newsCategory(widget.news.category),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _getCategoryColor(widget.news.category)),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.news.viewCount + 1}', // Optimistic +1
                            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Author row
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.accent, Color(0xFF7C3AED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text(TimeUtils.relativeTime(widget.news.createdAt), style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.8))),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.share_outlined, color: AppTheme.textSecondary), onPressed: () => _shareNews(l10n)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(
                    widget.news.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.3, letterSpacing: -0.3),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppTheme.dividerColor, AppTheme.dividerColor.withOpacity(0.1)]),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    widget.news.content,
                    style: TextStyle(fontSize: 16, color: AppTheme.textPrimary.withOpacity(0.9), height: 1.7, letterSpacing: 0.1),
                  ),

                  const SizedBox(height: 32),

                  // Reactions bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: _reactionEmojis.entries.map((e) {
                        final type = e.key;
                        final emoji = e.value;
                        final count = _reactionCounts[type] as int? ?? 0;
                        final isActive = _myReaction == type;

                        return GestureDetector(
                          onTap: () => _toggleReaction(type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? AppTheme.accent : AppTheme.dividerColor.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 20, height: 1.2)),
                                if (count > 0 || isActive) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
